A8255       EQU   0640H
B8255       EQU   0642H
MODE8255    EQU   0646H  
 
AD0809      EQU   0600H
 
CODE SEGMENT
    ASSUME CS:CODE
 
START: 
    ; 初始化8255 (A口输入, B口输出) 
    MOV DX, MODE8255
    MOV AL, 90H
    OUT DX, AL
 
    PUSH DS
    MOV AX, 0000H
    MOV DS, AX 
    
	MOV AX,OFFSET MIR7
	MOV SI,003CH	;偏移地址放入003C（对应的矢量地址）
	MOV [SI],AX
	MOV AX,CS
	MOV SI,003EH	;段地址放入003E（003C后一个字）
	MOV [SI],AX
	POP DS
    
    POP DS

    CLI;关闭cpu中断总开关，先开始初始化

 
	MOV AL,11H;ICW1
	OUT 20H,AL
	MOV AL,08H;ICW2 08H是起始的中断号，后续会自动分配
	OUT 21H,AL
	MOV AL,04H;ICW3
	OUT 21H,AL
	MOV AL,03H;ICW4
	OUT 21H,AL
	MOV AL,6FH;OCW1 只开放IR7和串口

	OUT 21H,AL
	
	STI;开开关
	


    MOV DX, AD0809 
    OUT DX, AL ;启动转换
    
MAIN_LOOP:
    JMP MAIN_LOOP
    

MIR7:
    MOV DX, AD0809 
    IN AL, DX
    
    MOV DX, B8255
    OUT DX, AL
    
    MOV AL, 20H
    OUT 20H, AL
    
    MOV DX, AD0809 
    OUT DX, AL ;启动转换
    
    IRET
    
L1:	LOOP L1
    POP CX
    RET
 
CODE ENDS
    END START