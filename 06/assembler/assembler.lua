Parser = require 'Parser'

inputFileName = arg[1]
inputFile = io.open(inputFileName, 'r')
inputText = inputFile:read('a')
parser = Parser(inputText)

outputFileName = inputFileName:gsub("%.%S*", '.hack')
outputFile = io.open(outputFileName, 'w')
outputFile:write(parser:output())