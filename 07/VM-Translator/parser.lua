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
    ["ne"] = "JNE",
}

--- @param str string
function Parser:init(str)
    self.code = str:gsub("//.-\n", "\n")
    self:parse()
end

--- @param addr string 
--- @param offset number
local function addrOffset(addr, offset)
    return string.format([[@%s
D = M
@%s
A = D + A
D = M
]], addr, offset)
end

--- @param cop string 
--- @param index number
local function compareString(cop, index)
    return 
        [[@SP
AM = M - 1
D = M
@SP
A = M - 1
D = M - D
@TRUE]].. index .. [[

D; ]] .. cop .. [[

@SP
A = M - 1
M = 0
@CONTINUE]].. index .. [[

0;JMP
(TRUE]].. index .. [[)
@SP
A = M - 1
M = -1
(CONTINUE]].. index .. [[)]]
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
            -- constant 才是
            if words[2] == "constant" then
                code = string.format([[@%s
D = A
]], words[3])
            else
                local offset = words[3]
                code = addrOffset(words[2], offset)
            end
            code = code .. [[
@SP
A = M
M = D
@SP
M = M + 1]]
        elseif words[1] == "pop" then
            local offset = words[3]
            local addr = addressTrans[words[2]]
            code = addrOffset(addr, offset) .. [[
D = A
@R13
M = D
@SP
M = M - 1
D = M
@R13
M = D]]
        else
            local cop = compareOP[words[1]]
            local bop = binaryOP[words[1]]
            local uop = unaryOP[words[1]]
            if cop then
                code = compareString(cop, copareIndex)
                copareIndex = copareIndex + 1
            elseif bop then
                code = [[@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M]] .. bop .. [[D]]
            else
                code = [[@SP
A = M - 1
M =]] .. uop .. [[M]]
            end
        end
        -- 添加原代码 注释
        code = code .. '\n//'.. line .. '\n'
        table.insert(self.compiled, code)
    end -- for line
end

--- @return string
function Parser:output()
    return table.concat(self.compiled, "\n")
end

return Parser
