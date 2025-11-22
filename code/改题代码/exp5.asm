;直线输出，开关按下一次输出两个一样的波形，波形种类按照锯齿、矩形、三角、阶梯循环
CODE SEGMENT
    ASSUME CS:CODE
START:
    MOV AX,0000H
    MOV DS,AX
    
    ;设置中断向量
	MOV AX,OFFSET MIR7
	MOV SI,003CH	;偏移地址放入003C（对应的矢量地址）
	MOV [SI],AX
	MOV AX,CS
	MOV SI,003EH	;段地址放入003E（003C后一个字）
	MOV [SI],AX
	
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
	
	STI;开开关
	
    MOV BL,00H		;BL作为选择波形的参数。0-3分别对应锯齿、矩形、三角、阶梯
    MOV BH,00H	;BH为周期计数器，记录目前产生了几个同样的波形。初始化为0



A1:
    CMP BL,00H
    JZ  JIETI
    CMP BL,01H
    JZ JUCHI
    CMP BL,02H
    JZ JUXING
    JMP SANJIAO
    
WAITLOOP:

    CMP BH,02H		; 若已完成 2 次：保持横线直到被中断打断并切换波形
    JNE A1
    
    MOV DX, 0600H   ;DAC0832接IOY0,0600H为控制端口地址
    MOV AL,00H
    OUT DX, AL          ; 输出直线
    JMP WAITLOOP      ; 无限循环, 直到被中断改变BL的值
  
  
JUCHI:
    MOV AL, 00H       	;起始为0
JC1: 
    OUT DX, AL        	
    CALL DELAY1      	;短延时
    INC AL
    CMP AL ,0FFH	;检测是否到达最大值
    JNE JC1			;不到最高则继续递增循环

    INC BH           ; 周期计数器+1
    JMP WAITLOOP

JUXING:
    MOV AL, 00H       	;起始为0
    OUT DX, AL
    CALL DELAY2      	;长延时
    MOV AL, 0FFH      	;再输出0FFH的波形
    OUT DX, AL
    CALL DELAY2       	;长延时

    INC BH           ; 周期计数器+1
    JMP WAITLOOP    ;如果已经2次, 进入等待循环
   
SANJIAO:
    MOV AL, 00H

;上升沿
SJ1:
    OUT DX, AL
    CALL DELAY1       	;短延时
    CMP AL, 0FFH
    JE SJ2           
    INC AL            	;将AL从00H递增到0FFH
    JMP SJ1


;下降沿
SJ2:
    OUT DX, AL
    CALL DELAY1      	;短延时
    DEC AL
    CMP AL, 00H
    JNE SJ2          ;如果不等于00H, 继续下降


    INC BH           ; 周期计数器+1
    JMP WAITLOOP    ;如果已经2次, 进入等待循环
    

JIETI:
;此处将0FEH修改为0FFH

    MOV AX, 0FEH      ;设置波形振幅最大值为0FEH
    MOV CL,05H         ;阶梯波中的阶梯数
    DIV CL             	;默认DIV用AX除以输入（阶梯数），得到每个台阶的高度
    MOV CL, AL         	;将上述除法的商从默认的AL转移到CL
    MOV CH, 00H        	;CH置0
    MOV AX, 0000H     	;AX初始化0000H
JT1:
    OUT DX, AL
    CMP AX, 0FFH       	;判断AX是否达到幅度上限
    JAE JT2              	;达到上限，表示一次阶梯波完整生成
    CALL DELAY2        	;长延时
    ADD AX, CX         	;用当前阶梯高度加上每个阶梯的高度得到下一阶梯的高度
    JMP JT1
JT2:
    INC BH           ; 周期计数器+1
    JMP WAITLOOP    ;如果已经2次, 进入等待循环

DELAY1:
    PUSH AX
    PUSH CX
    MOV AX, 01H   		;调节循环次数来改变周期
D1:                
    MOV CX, 0FFH
DD1: 
    LOOP DD1
    DEC AX
    CMP AX, 00H
    JNZ D1
    POP CX
    POP AX
    RET
 
DELAY2:
    PUSH AX
    PUSH CX
    MOV AX, 7FH   		;调节循环次数来改变周期
D2:                
    MOV CX, 0FFH
DD2: 
    LOOP DD2
    DEC AX
    CMP AX, 00H
    JNZ D2
    POP CX
    POP AX
    RET

MIR7:
	PUSH AX
    INC BL
    CMP BL, 04H
    JNE M
    MOV BL,00H		;BL=4的话下一次从0开始
M:
    MOV BH, 00H	;每次中断过后都要重置周期计数器
    POP AX
    IRET
    
CODE ENDS
    END START