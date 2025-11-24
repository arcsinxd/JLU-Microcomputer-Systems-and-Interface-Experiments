;考试题目。代码是凭记忆默写的，不敢打包票可以运行。但就改动了几个地方，接线按照改题代码的exp5接线就行
;默认输出3段阶梯波，按下KK1之后变为5段，再按变成7段，再按变回3段，循环往复。

;改动的地方：
;把A1的选择标签修改了一下，仅在0-2之内选择
;WAITLOOP中取消默认直线输出，直接循环执行A1
;三个阶梯波都是复制粘贴exp5的JIETI部分，仅改变了DIV上方的MOV CL,05H，将其替换为不同的阶梯数
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
    ;MOV BH,00H	;BH为周期计数器，记录目前产生了几个同样的波形。初始化为0



A1:
    CMP BL,00H
    JZ  JIETI1
    CMP BL,01H
    JZ JIETI2
    JMP JIETI3
    
WAITLOOP:

    ;CMP BH,02H		; 若已完成 2 次：保持横线直到被中断打断并切换波形
    ;JNE A1
    
    ;MOV DX, 0600H   ;DAC0832接IOY0,0600H为控制端口地址
    ;MOV AL,00H
    ;OUT DX, AL          ; 输出直线
    JMP A1     ; 无限循环, 直到被中断改变BL的值
  
  
JIETI1:
;此处将0FEH修改为0FFH

    MOV AX, 0FEH      ;设置波形振幅最大值为0FEH
    MOV CL,03H         ;阶梯波中的阶梯数
    DIV CL             	;默认DIV用AX除以输入（阶梯数），得到每个台阶的高度
    MOV CL, AL         	;将上述除法的商从默认的AL转移到CL
    MOV CH, 00H        	;CH置0
    MOV AX, 0000H     	;AX初始化0000H
JT11:
    OUT DX, AL
    CMP AX, 0FFH       	;判断AX是否达到幅度上限
    JAE JT12              	;达到上限，表示一次阶梯波完整生成
    CALL DELAY2        	;长延时
    ADD AX, CX         	;用当前阶梯高度加上每个阶梯的高度得到下一阶梯的高度
    JMP JT11
JT12:
    INC BH           ; 周期计数器+1
    JMP WAITLOOP    ;如果已经2次, 进入等待循环

JIETI2:
;此处将0FEH修改为0FFH

    MOV AX, 0FEH      ;设置波形振幅最大值为0FEH
    MOV CL,05H         ;阶梯波中的阶梯数
    DIV CL             	;默认DIV用AX除以输入（阶梯数），得到每个台阶的高度
    MOV CL, AL         	;将上述除法的商从默认的AL转移到CL
    MOV CH, 00H        	;CH置0
    MOV AX, 0000H     	;AX初始化0000H
JT21:
    OUT DX, AL
    CMP AX, 0FFH       	;判断AX是否达到幅度上限
    JAE JT22              	;达到上限，表示一次阶梯波完整生成
    CALL DELAY2        	;长延时
    ADD AX, CX         	;用当前阶梯高度加上每个阶梯的高度得到下一阶梯的高度
    JMP JT21
JT22:
    INC BH           ; 周期计数器+1
    JMP WAITLOOP    ;如果已经2次, 进入等待循环

JIETI3:
;此处将0FEH修改为0FFH

    MOV AX, 0FEH      ;设置波形振幅最大值为0FEH
    MOV CL,07H         ;阶梯波中的阶梯数
    DIV CL             	;默认DIV用AX除以输入（阶梯数），得到每个台阶的高度
    MOV CL, AL         	;将上述除法的商从默认的AL转移到CL
    MOV CH, 00H        	;CH置0
    MOV AX, 0000H     	;AX初始化0000H
JT31:
    OUT DX, AL
    CMP AX, 0FFH       	;判断AX是否达到幅度上限
    JAE JT32              	;达到上限，表示一次阶梯波完整生成
    CALL DELAY2        	;长延时
    ADD AX, CX         	;用当前阶梯高度加上每个阶梯的高度得到下一阶梯的高度
    JMP JT31
JT32:
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