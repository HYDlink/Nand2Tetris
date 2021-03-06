Main.fibonacci
//function Main.fibonacci 0

@ARG
D = M
@0
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push argument 0

@2
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 2

@SP
AM = M - 1
D = M
@SP
A = M - 1
D = M - D
@TRUE1
D; JLT
@SP
A = M - 1
M = 0
@CONTINUE1
0;JMP
(TRUE1)
@SP
A = M - 1
M = -1
(CONTINUE1)
//lt                     

@SP
AM = M - 1
D = M
@Main.fibonacci$IF_TRUE
D; JNE

//if-goto IF_TRUE

@Main.fibonacci$IF_FALSE;
JMP
//goto IF_FALSE

(Main.fibonacci$IF_TRUE)
//label IF_TRUE          

@ARG
D = M
@0
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push argument 0        

@LCL
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
D = M
@1
A = D - A
D = M
@THIS
M = D
D = M
@2
A = D - A
D = M
@THAT
M = D
D = M
@3
A = D - A
D = M
@ARG
M = D
D = M
@4
A = D - A
D = M
@LCL
M = D
@R14
A = D
0; JMP
// goto RET
//return

(IF_FALSE)
//label IF_FALSE         

@ARG
D = M
@0
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push argument 0

@2
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 2

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M - D
//sub

@ReturnLabel1
D = A
@SP
A = M
M = D
@SP
M = M + 1

@LCL
D = A
@SP
A = M
M = D
@SP
M = M + 1

@ARG
D = A
@SP
A = M
M = D
@SP
M = M + 1

@THIS
D = A
@SP
A = M
M = D
@SP
M = M + 1

@THAT
D = A
@SP
A = M
M = D
@SP
M = M + 1

@SP
D = M
@6
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@s
0; JMP
(Main.fibonacci)
        
//call Main.fibonacci 1  

@ARG
D = M
@0
A = D + A
D = M
@SP
A = M
M = D
@SP
M = M + 1
//push argument 0

@1
D = A
@SP
A = M
M = D
@SP
M = M + 1
//push constant 1

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M - D
//sub

@ReturnLabel2
D = A
@SP
A = M
M = D
@SP
M = M + 1

@LCL
D = A
@SP
A = M
M = D
@SP
M = M + 1

@ARG
D = A
@SP
A = M
M = D
@SP
M = M + 1

@THIS
D = A
@SP
A = M
M = D
@SP
M = M + 1

@THAT
D = A
@SP
A = M
M = D
@SP
M = M + 1

@SP
D = M
@6
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@s
0; JMP
(Main.fibonacci)
        
//call Main.fibonacci 1  

@SP
AM = M - 1
D = M
@SP
A = M - 1
M = M + D
//add                    

@LCL
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
D = M
@1
A = D - A
D = M
@THIS
M = D
D = M
@2
A = D - A
D = M
@THAT
M = D
D = M
@3
A = D - A
D = M
@ARG
M = D
D = M
@4
A = D - A
D = M
@LCL
M = D
@R14
A = D
0; JMP
// goto RET
//return
