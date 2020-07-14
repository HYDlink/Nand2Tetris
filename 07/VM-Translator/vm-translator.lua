Parser = require 'Parser'
AsmParser = require 'asmParser'

inputFileName = arg[1]
inputFile = io.open(inputFileName, 'r')
inputText = inputFile:read('a')
parser = Parser(inputText)

asm = parser:output()

asmOutputFileName = inputFileName:gsub("%.%S*", '.asm')
asmOutputFile = io.open(asmOutputFileName, 'w')
asmOutputFile:write(asm)

asmParser = AsmParser(asm)
hack = asmParser:output()

hackOutputFileName = inputFileName:gsub("%.%S*", '.hack')
hackOutputFile = io.open(hackOutputFileName, 'w')
hackOutputFile:write(hack)