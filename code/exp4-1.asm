AD0809 EQU 0600H

PUBLIC  VALUE             
DATA    SEGMENT
VALUE   DB ?          ;定义一个8位的变量VALUE，初始值不定
DATA    ENDS
CODE    SEGMENT
        ASSUME CS:CODE, DS:DATA
START:  MOV AX, DATA
        MOV DS, AX
        MOV DX, AD0809    
        OUT DX, AL	;AL是什么不重要，OUT这个动作是ADC的开始信号
        CALL DELAY
        IN  AL, DX         
        MOV VALUE, AL     
        JMP START         
DELAY:             ;延时，给CPU一段时间转换
    PUSH CX        
    PUSH AX
    MOV CX,0FFFFH
L1: LOOP L1    
    POP AX
    POP CX 
    RET
CODE    ENDS
        END START