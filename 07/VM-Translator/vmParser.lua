local class = require "class"
local Parser = class {}

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

--- @param str string
function Parser:init(str)
    self.code = str:gsub("//.-\n", "\n")
    self:parse()
end

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

local staticStart = 256
local maxStaticCount = 0

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
        maxStaticCount = math.max(offsetNum, maxStaticCount)
        local addr = staticStart + offsetNum
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
local function compareString(cop, index)
    return translate.pop .. [[

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
(TRUE]] .. index .. [[)
@SP
A = M - 1
M = -1
(CONTINUE]] .. index .. [[)]]
end


function Parser:parse()
    self.compiled = {}
    local copareIndex = 1
    for line in self.code:gmatch("[^\r\n]+") do
        local words = {}
        local code = ""
        for word in line:gmatch("%S+") do
            table.insert(words, word)
        end

        if words[1] == "push" then
            -- constant 表示直接将立即数压入栈中
            if words[2] == "constant" then
                code = string.format([[@%s
D = A
]], words[3]) .. translate.push
            else
                local offset = words[3]
                code = addrOffset(words[2], offset) .. "D = M\n" .. translate.push
            end
        elseif words[1] == "pop" then
            local offset = words[3]
            -- 需要先将 目标写入地址 记录，然后再弹出数据，再取出目标地址，对其进行写入
            code = addrOffset(words[2], offset) .. string.format([[
D = A
@R13
M = D
%s
@R13
A = M
M = D]], translate.pop)
        else
            local cop = compareOP[words[1]]
            local bop = binaryOP[words[1]]
            local uop = unaryOP[words[1]]
            if cop then
                code = compareString(cop, copareIndex)
                copareIndex = copareIndex + 1
            elseif bop then
                code = translate.pop .. [[

@SP
A = M - 1
M = M ]] .. bop .. [[ D]]
            else
                code = [[@SP
A = M - 1
M =]] .. uop .. [[M]]
            end
        end
        -- 添加原代码 注释
        -- code = code .. '\n//'.. line .. '\n'
        table.insert(self.compiled, code)
    end -- for line
end

--- @return string
function Parser:output()
    return table.concat(self.compiled, "\n")
end

return Parser
