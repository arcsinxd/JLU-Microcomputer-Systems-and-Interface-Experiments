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
        MOV AL, 10H             ;计数器0，读写低8位，方式0，二进制
        OUT DX, AL		;配置发送
        
        MOV DX, A8254
        MOV AL, 04H		;按动5次后计数到0，8254输出信号
        OUT DX, AL
        STI
 
MAIN:   
        JMP MAIN
 
MIR7:   
        MOV AX, 014DH	;打印M
        INT 10H  

        MOV DX, A8254	;重置次数
        MOV AL, 04H
        OUT DX, AL

        IRET
CODE    ENDS
        END  START 