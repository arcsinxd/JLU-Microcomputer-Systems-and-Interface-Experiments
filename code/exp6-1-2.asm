A8254    EQU  0600H
B8254    EQU  0602H
C8254    EQU  0604H
MODE8254  EQU  0606H
 
SSTACK  SEGMENT STACK
        DW 32 DUP(?)
SSTACK  ENDS
 
CODE    SEGMENT
        ASSUME CS:CODE, SS:SSTACK
START:  
        MOV DX, MODE8254
        MOV AL, 36H             ;计数器0，先低8位再高8位，方式3，二进制
        OUT DX, AL

        MOV DX, A8254
        MOV AL, 00H		;4800H等于18432的频率输入
        OUT DX, AL
        MOV AL, 48H
        OUT DX, AL
        
MAIN:   
        JMP MAIN
        
CODE    ENDS
        END  START