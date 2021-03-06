@3030
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 3030

@THIS
D = A
@R13
M = D
@SP
AM = M - 1
D = M
@R13
A = M
M = D
//pop pointer 0

@3040
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 3040

@THAT
D = A
@R13
M = D
@SP
AM = M - 1
D = M
@R13
A = M
M = D
//pop pointer 1

@32
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 32

@THIS
D = M
@2
A = D + A
D = A
@R13
M = D
@SP
AM = M - 1
D = M
@R13
A = M
M = D
//pop this 2

@46
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 46

@THAT
D = M
@6
A = D + A
D = A
@R13
M = D
@SP
AM = M - 1
D = M
@R13
A = M
M = D
//pop that 6

@THIS
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push pointer 0

@THAT
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push pointer 1

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M + D
//add

@THIS
D = M
@2
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push this 2

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M - D
//sub

@THAT
D = M
@6
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push that 6

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M + D
//add
