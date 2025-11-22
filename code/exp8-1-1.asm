;注意：接线和pdf不完全一致，8255A口PA0-PA5接到X6-X1
A8255 EQU 0600H
B8255 EQU 0602H
C8255 EQU 0604H  
MODE8255 EQU 0606H
 
DATA SEGMENT
    TAB:       ;段码表
        DB 3FH    ;0
        DB 06H    ;1
        DB 5BH    ;2
        DB 4FH    ;3
        DB 66H    ;4
        DB 6DH    ;5
        DB 7DH    ;6
        DB 07H    ;7
        DB 7FH    ;8
        DB 6FH    ;9
DATA ENDS
 
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX   
        
    MOV DX,MODE8255
    MOV AL,81H		;AB口皆为输出，A口位选（选择哪一个数码管），B口段选（选择哪个数字）
    OUT DX,AL    
    
    MOV DX,A8255
    MOV AL,00H
    OUT DX,AL
    
    MOV DX,B8255
    MOV AL,00H
    OUT DX,AL
 
    LEA BX,TAB	;LEA:加载有效地址。该指令将TAB的起始内存地址载入BX中
    MOV SI,00H	;相当于索引
    MOV AL,11011111B  ;初始选择最高位数码管，即最右端的数码管    
 
MAIN:  
    CMP AL,01111111B  ;判断数码管是否到达最左端
    JE AA0
    
    MOV DX,A8255 
    OUT DX,AL         ;选择数码管
    
    PUSH AX
    MOV DX,B8255
    MOV AL,[BX+SI]
    OUT DX,AL
    CALL DELAY  
    POP AX 
     
    ROR AL,01H	;右循环移位选码
    JMP MAIN
    
;更换数字
AA0:
    INC SI
    MOV AL,11011111B   ;重置位置，下一次从最右边的数码管开始
    CMP SI,0AH		;判断是否显示完0-9
	JE AA1
	JMP MAIN
AA1:
    MOV SI,00H  	;重置索引
    JMP MAIN     
 
DELAY:
    PUSH CX
    MOV CX,0FFFFH
D0:
    PUSH AX
    POP AX
    LOOP D0
    POP CX
    RET
    
CODE ENDS
     END START