// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.
@mult
M = 0	// D = M 的操作，是赋值一块内容，而不是复制变量
@1
D = M	// D = R1
@END
D;JEQ	// if (R1 == 0) return mult;
@left	// 剩余需要乘法的次数
M = D	// left = R1
(LOOP)
@0
D = M	// D = R0
@left
M = M - 1	// left = left - 1
@mult
M = M + D 	// mult = mult + R0

@left	// if (left > 0) continue;
D = M
@LOOP
D;JGT
(END)
@mult
D = M	// D = mult
@2
M = D	// R[2] = mult