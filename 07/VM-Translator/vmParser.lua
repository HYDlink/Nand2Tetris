local class = require "class"
local CodeWriter = require "vmCodeWriter"
local Parser = class {}

--- @param str string
function Parser:init(str)
    self.code = str:gsub("//.-\n", "\n")
    CodeWriter.init()
    self:parse()
end

function Parser:parse()
    self.compiled = {}
    for line in self.code:gmatch("[^\r\n]+") do
        local words = {}
        local code = ""
        for word in line:gmatch("%S+") do
            table.insert(words, word)
        end

        code = CodeWriter.translateLine(words)
        if code == nil then
            print(words[1])
        end

        -- 添加原代码 注释
        code = code .. "\n//" .. line .. "\n"
        table.insert(self.compiled, code)
    end -- for line
end

--- @return string
function Parser:output()
    local bootstrapCode = "@SP\nM=256\n@Sys.init\n0;JMP"
    return (self.multiFile and bootstrapCode or "") .. table.concat(self.compiled, "\n")
end

return Parser
