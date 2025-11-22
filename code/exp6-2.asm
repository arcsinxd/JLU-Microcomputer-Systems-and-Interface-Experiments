A8254    EQU  0600H
B8254    EQU  0602H
C8254    EQU  0604H
MODE8254  EQU  0606H
 
A8255 EQU 0640H
B8255 EQU 0642H
C8255 EQU 0644H
MODE8255 EQU 0646H
 
SSTACK  SEGMENT STACK
        DW 32 DUP(?)
SSTACK  ENDS
 
CODE    SEGMENT
        ASSUME CS:CODE, SS:SSTACK
START:  
        PUSH DS
        
        MOV DX,MODE8255
        MOV AL,80H
        OUT DX,AL
        
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
        MOV AL, 00H
        OUT DX, AL
        MOV AL, 48H
        OUT DX, AL
        STI
 
        MOV DX,B8255		;灯全灭
        MOV AL,00H
MAIN:   
        OUT DX,AL		;不断更新灯的状态
        JMP MAIN
 
MIR7:   
        CMP AL,0FFH		;检测是否全亮
        JE NEXT
        ROL AL,1			;左移后+1，逐渐每位置1
        INC AL
        JMP EXIT
NEXT:
        MOV AL,00H
EXIT:  
        IRET
        
CODE    ENDS
        END  START