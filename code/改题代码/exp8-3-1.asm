;单位秒表计时，1-9s
;注意：接线和pdf不完全一致，8255A口PA0-PA5接到X6-X1
A8255 EQU 0600H
B8255 EQU 0602H
C8255 EQU 0604H
MODE8255 EQU 0606H


 ;8254接IOY1
A8254 EQU 0640H
B8254 EQU 0642H 
C8254 EQU 0644H 
MODE8254 EQU 0646H
 
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
   FLAG DB 00H;用于保存C口读进来的开关信号
DATA ENDS   
 
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA  
START:
 	MOV AX,DATA
	MOV DS,AX
	MOV DX,MODE8255
	MOV AL,81H	;AB口皆为输出，A口位选（选择哪一个数码管），B口段选（选择哪个数字）
	OUT DX,AL

	PUSH DS
	MOV AX,0000H
	MOV DS,AX
	
	MOV AX,OFFSET MIR7
	MOV SI,003CH	;偏移地址放入003C（对应的矢量地址）
	MOV [SI],AX
	MOV AX,CS
	MOV SI,003EH	;段地址放入003E（003C后一个字）
	MOV [SI],AX
	POP DS
 
    CLI;关闭cpu中断总开关，先开始初始化

 
	MOV AL,11H;ICW1
	OUT 20H,AL
	MOV AL,08H;ICW2 08H是起始的中断号，后续会自动分配
	OUT 21H,AL
	MOV AL,04H;ICW3
	OUT 21H,AL
	MOV AL,03H;ICW4 07改为03 全嵌套+自动结束中断
	OUT 21H,AL
	MOV AL,6FH;OCW1 2F改为6F，只开放IR7和串口
	OUT 21H,AL
   
        MOV DX, MODE8254
        MOV AL, 36H             ;计数器0，先低8位再高8位，方式3，二进制
        OUT DX, AL

        MOV DX, A8254
        MOV AL, 00H		;4800H等于18432的频率输入
        OUT DX, AL
        MOV AL, 48H
        OUT DX, AL 
    STI
	
	LEA BX,TAB
	MOV SI,00H		;字符串的索引（0-9）

MAIN:
	;固定最右位数码管输出
	MOV AL,11111110B
	MOV DX,A8255
	OUT DX,AL

	MOV AL,[BX+SI]
	MOV DX,B8255
	OUT DX,AL

	CALL DELAY
	JMP MAIN

MIR7:
	INC SI
	CMP SI,0AH
	JNE EXIT
	MOV SI,00H
EXIT:
	IRET	
	
DELAY:
    PUSH CX
    MOV CX,00FFH
L1:
    LOOP L1
    POP CX
    RET
    
CODE ENDS
     END START