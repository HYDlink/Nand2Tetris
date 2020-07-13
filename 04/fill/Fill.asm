// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.


(LOOP)



(CLEAR)

// curPoint = screen
@SCREEN
D = A
@curPoint
M = D

(CLEARLOOP)

// RAM[curPoint] = 0
@curPoint
A = M	// 将curPoint 的值作为地址推入 A，之后访问 M，就是访问 RAM[A] 了
M = 0

// ++curPoint
@curPoint
M = M + 1

// while (curPoint < keyboard)
@curPoint
D = M
@KBD
D = D - A
@CLEARLOOP
D;JLT

(CLEAREND)

// if (RAM[keyboard] > 0) goto FILLEND;
@KBD
D = M
@FILLEND
D;JGT

(FILL)

// curPoint = screen
@SCREEN
D = A
@curPoint
M = D

(FILLLOOP)

// RAM[curPoint] = -1
@curPoint
A = M	// 将curPoint 的值作为地址推入 A，之后访问 M，就是访问 RAM[A] 了
M = -1

// ++curPoint
@curPoint
M = M + 1

// while (curPoint < keyboard)
@curPoint
D = M
@KBD
D = D - M
@FILLLOOP
D;JLT

(FILLEND)

@LOOP
0;JMP