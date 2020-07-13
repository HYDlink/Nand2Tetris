class = require "class"
keyword = require "keyword"

--- @class Parser
Parser =
    class {
    code = "",
    compiled = {},
    commandType = "",
    symbols = {}
}

--- @param str string
function Parser:init(str)
    self.code = str
    self.compiled = {}
    self.commandType = ""
    self.symbols = {}
    self.commentCleared = string.gsub(self.code, "//.-\n", "\n")
    -- 先清除中间的空行，然后处理头尾空行
    -- self.emptyLineCleared = delEmptyLines(self.commentCleared)
    -- 于其清除空余行，不如把所有的非空行找出来然后合并
    -- 甚至，只对非空行进行解析

    self.simplifiedCode = string.gsub(self.commentCleared, "[ \t]", "")
    self.symbolLessCode = ""
    self:getSymbols()
    self:replaceSymbol()
    -- print(self.symbolLessCode)
    self:parse()
end

function Parser:getSymbols()
    -- 指令计数器，就命名成 pc 了，代表当前指令的地址，如果当前行是 label，那么就代表下一行指令的地址
    local pc = 0
    for line in string.gmatch(self.simplifiedCode, "[^\r\n]+") do
        if line:sub(1, 1) == "(" and line:sub(-1, -1) == ")" then
            local label = line:sub(2, -2)
            self.symbols[label] = pc
        else
            pc = pc + 1
        end
    end

    -- 再一次遍历，查找所有非 label 符号，并赋予地址
    -- 当前也可以在第一次遍历的时候就这么做，只不过之后分配的地址会不一样，这个倒是不怎么影响程序的运行实现
    local addr = 0
    for line in string.gmatch(self.simplifiedCode, "[^\r\n]+") do
        if line:sub(1, 1) == "@" and (line:find("%a")) == 2 then
            local symbol = line:sub(2)
            -- 先设置成 -1 意义为 undefined
            if self.symbols[symbol] == nil then
                self.symbols[symbol] = addr
                addr = addr + 1
            end
        end
    end
end

function Parser:replaceSymbol()
    self.symbolLessCode = self.simplifiedCode:gsub("%([^)]+%)", "")
    for k, v in pairs(self.symbols) do
        -- print(k, v)
        self.symbolLessCode = self.symbolLessCode:gsub(k, tostring(v))
    end
end

function Parser:parse()
    self.compiled = {}  -- 每一行汇编代码转换后的机器码，最后会使用 table.concat 来合并
    -- 对每行进行解析
    for line in string.gmatch(self.symbolLessCode, "[^\r\n]+") do
        local commandType
        local code
        if line:sub(1, 1) == "@" then
            commandType = "A"
            -- 从立即数转换为 15 位二进制数
            local num = tonumber(string.sub(line, 2))
            code = "0" .. tobinary(num, 15)
        else
            commandType = "C"
            local compute, dest, jump
            local destCompiledTable = {}
            local destCompiled = "000"

            -- 找到 = 来确认是赋值操作，找到 ; 来确认是跳转操作
            local eqPos = line:find("=")
            local commaPos = line:find(";")
            if eqPos then
                dest = line:sub(1, eqPos - 1)
                compute = line:sub(eqPos + 1)
            elseif commaPos then
                compute = line:sub(1, commaPos - 1)
                jump = line:sub(commaPos + 1)
            end

            -- 处理 dest 中的寄存器序列，如果没有 dest 部分的语句，那么 destCompiled 默认为 '000'，已经放在变量初始化了
            if dest then
                table.insert(destCompiledTable, dest:find("A") and "1" or "0")
                table.insert(destCompiledTable, dest:find("D") and "1" or "0")
                table.insert(destCompiledTable, dest:find("M") and "1" or "0")
                destCompiled = table.concat(destCompiledTable)
            end

            code = "111" .. (keyword.comp[compute] or "0000000") .. destCompiled .. (keyword.jump[jump] or "000")
        end
        table.insert(self.compiled, code)
    end
    print('Parse Compelete!')
end

--- @return string
function Parser:output()
    return table.concat(self.compiled, "\n")
end

function tobinary(num, len)
    local t = {}
    local shifted = num
    while shifted ~= 0 and #t < len do
        table.insert(t, tostring(shifted & 1))
        shifted = shifted >> 1
    end
    while #t < len do
        table.insert(t, "0")
    end
    local txt = table.concat(t)
    txt = txt:reverse()
    return txt
end

-- 这个函数没有清除末尾行
function delEmptyLines(txt)
    if #txt == 0 then
        return
    end
    local chg, n = false
    while true do
        txt, n = string.gsub(txt, "(\r?\n)%s*\r?\n", "%1")
        if n == 0 then
            break
        end
        chg = true
    end
    return txt
end

return Parser
