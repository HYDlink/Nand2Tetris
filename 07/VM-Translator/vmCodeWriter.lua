local class = require "class"
local CodeWriter = {}
-- 代码嵌入规矩，预制代码，根据关键词进行分配的代码，比如 addrOffset 后面的代码，放在前面的，末尾不添加换行符

local translate = {
    -- 将寄存器 D 中的值，压入栈中
    push = [[
@SP
A = M
M = D
@SP
M = M + 1]],
    -- 将栈顶中的值，弹出，并放入 D 中
    pop = [[
@SP
AM = M - 1
D = M]]
}

local addressTrans = {
    argument = "ARG",
    ["local"] = "LCL",
    this = "THIS",
    that = "THAT",
    static = nil -- TODO
}

local binaryOP = {
    ["add"] = "+",
    ["sub"] = "-",
    ["or"] = "|",
    ["and"] = "&"
}

local unaryOP = {
    ["not"] = "!",
    ["neg"] = "-"
}

local compareOP = {
    ["lt"] = "JLT",
    ["le"] = "JLE",
    ["gt"] = "JGT",
    ["ge"] = "JGE",
    ["eq"] = "JEQ",
    ["ne"] = "JNE"
}

--- @type table<string, function>
local controlWord = {
    ["if-goto"] = function(label)
        return translate.pop .. string.format([[

@%s
D; JNE
]], label)
    end,
    ["goto"] = function(label)
        return string.format("@%s;\nJMP", label)
    end,
    ["label"] = function(label)
        return string.format("(%s)", label)
    end
}

--- 最后会将结果地址放入 A 寄存器中
--- @param addr string
--- @param offset number
local function addrOffset(addrWord, offset)
    if addrWord == "temp" then
        -- 5 是 temp 段开始的位置
        local addr = 5 + tonumber(offset)
        return string.format("@%d\n", addr)
    elseif addrWord == "static" then
        -- TODO static 处理
        local offsetNum = tonumber(offset)
        CodeWriter.maxStaticCount = math.max(offsetNum, CodeWriter.maxStaticCount)
        local addr = CodeWriter.staticStart + offsetNum
        return string.format("@%d\n", addr)
    elseif addrWord == "pointer" then
        return offset == "0" and "@THIS\n" or "@THAT\n"
    else
        local addr = addressTrans[addrWord]
        return string.format([[@%s
D = M
@%s
A = D + A
]], addr, offset)
    end
end

--- 跳转指令的完全翻译
--- @param cop string 条件跳转的汇编命令
--- @param index number 第几个跳转指令，用于特化标签
local function compareCode(cop, index)
    return translate.pop ..
        [[

@SP
A = M - 1
D = M - D
@TRUE]] ..
            index ..
                [[

D; ]] ..
                    cop ..
                        [[

@SP
A = M - 1
M = 0
@CONTINUE]] ..
                            index ..
                                [[

0;JMP
(TRUE]] ..
                                    index .. [[)
@SP
A = M - 1
M = -1
(CONTINUE]] .. index .. [[)]]
end

------------------------ 内置函数 ------------------------

--- 解析 push 语句
--- @param words table<number, string>
local function parsePush(words)
    -- constant 表示直接将立即数压入栈中
    if words[2] == "constant" then
        return string.format([[@%s
D = A
]], words[3]) .. translate.push
    else
        local offset = words[3]
        return addrOffset(words[2], offset) .. "D = M\n" .. translate.push
    end
end

--- 解析 pop 语句
--- @param words table<number, string>
local function parsePop(words)
    local offset = words[3]
    -- 需要先将 目标写入地址 记录，然后再弹出数据，再取出目标地址，对其进行写入
    return addrOffset(words[2], offset) ..
        string.format([[
D = A
@R13
M = D
%s
@R13
A = M
M = D]], translate.pop)
end

--- 解析运算符单词
--- @param words table<number, string>
local function parseBinaryOP(words)
    return translate.pop .. [[

@SP
A = M - 1
M = M ]] .. binaryOP[words[1]] .. [[ D]]
end
local function parseUnaryOP(words)
    return [[@SP
A = M - 1
M =]] .. unaryOP[words[1]] .. [[M]]
end
local function parseCompareOP(words)
    CodeWriter.compareLblIdx = CodeWriter.compareLblIdx + 1
    return compareCode(compareOP[words[1]], CodeWriter.compareLblIdx)
end

--- 解析 call 语句
--- @param words table<number, string>
local function parseCall(words)
    CodeWriter.returnLblIdx = CodeWriter.returnLblIdx + 1
    local returnLabel = string.format("ReturnLabel%d", CodeWriter.returnLblIdx)
    CodeWriter.funcName = words[2]
    local argOffset = tonumber(words[3]) + 5
    local pushAddr = function(addr)
        return string.format("@%s\nD = A\n%s\n", addr, translate.push)
    end
    return string.format(
        [[
%s
%s
%s
%s
%s
@SP
D = M
@%d
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@s
0; JMP
(%s)
        ]],
        pushAddr(returnLabel),
        pushAddr("LCL"),
        pushAddr("ARG"),
        pushAddr("THIS"),
        pushAddr("THAT"),
        argOffset,
        CodeWriter.funcName,
        returnLabel
    )
end

local function parseFunc(words)
    CodeWriter.funcName = words[2]
    local varCount = tonumber(words[3])
    return string.format("(@%s)", CodeWriter.funcName) ..
        string.rep([[

@SP
A = M
M = 0
@SP
M = M + 1]], varCount)
end

local function parseReturn()
    CodeWriter.funcName = nil
    local function frameOffset(addrWord, offset)
        return string.format([[D = M
@%s
A = D - A
D = M
@%s
M = D]], offset, addrWord)
    end
    return string.format(
        [[@LCL
D = M
@R13
M = D
// Frame = LCL
@5
A = D - A	// Frame - 5
D = M // *(Frame - 5)
@R14
M = D
// Ret = *(Frame - 5)
@SP
AM = M - 1
D = M
// D = pop()
@ARG
A = M
M = D
// *ARG = pop()
%s
%s
%s
%s
@R14
A = D
0; JMP
// goto RET]],
        frameOffset("THIS", "1"),
        frameOffset("THAT", 2),
        frameOffset("ARG", "3"),
        frameOffset("LCL", "4")
    )
end

function CodeWriter.init()
    CodeWriter.reset()
    -- 因为 vm 所有的语句，都会有预先的单词，根据这些预先的单词，来分配使用的 parse 函数即可
    CodeWriter.funcTable = {
        push = parsePush,
        pop = parsePop,
        ["function"] = parseFunc,
        ["call"] = parseCall,
        ["return"] = parseReturn
    }

    for k, v in pairs(controlWord) do
        CodeWriter.funcTable[k] = function(words)
            local label = (CodeWriter.funcName and (CodeWriter.funcName .. "$") or "") .. words[2]
            return controlWord[k](label)
        end
    end

    for k, v in pairs(binaryOP) do
        CodeWriter.funcTable[k] = parseBinaryOP
    end

    for k, v in pairs(unaryOP) do
        CodeWriter.funcTable[k] = parseUnaryOP
    end

    for k, v in pairs(compareOP) do
        CodeWriter.funcTable[k] = parseCompareOP
    end
end

--- 重置 CodeWriter 中，记录的函数名，静态地址
--- @public
function CodeWriter.reset()
    CodeWriter.compareLblIdx = 0
    CodeWriter.returnLblIdx = 0
    -- 记录当前所 parse 过，但没有遇到 return 的函数们，这是一个堆栈
    -- local functionStack = {}
    -- 但实际 VM 并没有 内嵌函数 做法，因此采用一个 CodeWriter.funcName 来记录当前函数即可了
    CodeWriter.funcName = nil
    CodeWriter.staticStart = 256
    CodeWriter.maxStaticCount = 0
end

--- @public
function CodeWriter.translateLine(words)
    return CodeWriter.funcTable[words[1]](words)
end

function CodeWriter.newVM()
    CodeWriter.staticStart = CodeWriter.staticStart + CodeWriter.maxStaticCount
end

return CodeWriter
