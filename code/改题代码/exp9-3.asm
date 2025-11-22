;最左侧数码管显示按键行数，最右侧显示列数
;大体和实验九基础实验差不多，只改动了个别地方
A8255 EQU 0600H
B8255 EQU 0602H
C8255 EQU 0604H
MODE8255 EQU 0606H
DATA SEGMENT
TAB:				;TAB表用于记录0 ~ F的段选码
	DB 3FH,06H,5BH,4FH 
	DB 66H,6DH,7DH,07H 
	DB 7FH,6FH,77H,7CH 
	DB 39H,5EH,79H,71H
T1	DB 00H			;Ti表用于记录6个数码管的段选码（显示数字）
T2	DB 00H
T3	DB 00H
T4	DB 00H
T5	DB 00H
T6	DB 00H
FLAG DB 00H			;FLAG变量用于互斥上锁解锁操作
DATA ENDS
CODE SEGMENT
	ASSUME CS:CODE,DS:DATA
START:
	MOV AX,DATA		;导入DATA
	MOV DS,AX
	
	MOV AX,00H		;寄存器A清零
	LEA BX,TAB		;记录TAB表首地址
	
    	MOV DX,MODE8255
    	MOV AL,89H	;AB口均输出，C口8位输入
    	OUT DX,AL    
	
MAIN:
	MOV AL,11110111B	;从最右侧那列开始，从右往左扫描
	MOV CX,04H			;一共需要扫描4列，循环4次
M1:
	MOV DX,A8255
	OUT DX,AL
	ROR AL,1
	
	PUSH AX			;保存列选信号
	PUSH CX			;保存循环计数
	MOV DX,C8255
	IN AL,DX			;低电平有效（0表示被按下）
	AND AL,00001111B			;高四位清空，低四位保持不变
	CMP AL,00001111B			;如果低四位是1111，表明没有按键按下
	JE M2
	CALL SHOW		;没有跳去M2，则表明有按键按下
	JMP M3		;如果有按键按下，则跳过M2（互斥计数）阶段
M2:
	CMP FLAG,00H	;维持互斥信号，FLAG=MAX(0,FLAG-1)
	JE M3			;FLAG=0表示4列都没有按键按下
	DEC FLAG		;每扫描一列，并且没有按键按下时，FLAG自减1次
M3:
	CALL CLEAR		;显示数码管的内容
	POP CX		;先取出循环计数
	POP AX		;再取出列选信号
	
	CALL DELAY	;稍微延迟
	LOOP M1
	
	JMP MAIN
	
SHOW:
	CMP FLAG,00H		;是否存在互斥，非0表示存在互斥。
	JNE DFI
	
	NOT AL			;取反，将开关信号从低电平有效转为高电平有效
	AND AX,00001111B		;AND保留低4位（详情见下边第4点"关于按键判断"）
	MOV SI,00H
	
	CMP AL,0001B		;确定是哪一行
		JE D1
	CMP AL,0010B
		JE D2
	CMP AL,0100B
		JE D3
	CMP AL,1000B
		JE D4
D1: MOV SI,01H	;每行第一个按键的编号。用SI存储，立刻存到T6防止丢失
	JMP D5
D2: MOV SI,02H
	JMP D5
D3: MOV SI,03H
	JMP D5
D4: MOV SI,04H
	JMP D5
D5:	
	LEA BX,TAB		;把TAB的首地址放到BX
	MOV AL,[BX+SI]		;将按键索引值放到T1
	MOV T6,AL		;T1是最右端的数码管
	

    MOV AL, CL	;CL存的是扫描4列还剩几次没扫,列0剩1次，列1剩2次...
	MOV SI,AX	;移到SI及时保存
	MOV AL,[BX+SI]		;将按键索引值放到T1
	MOV T1,AL			;T1是最右端的数码管
	
	;CALL DELAY			;不注释的话会导致和行号列号对应的位置短暂出现行数（原因未知）
DFI:
	MOV FLAG,04H		;FLAG初值设置（上锁）
	RET
	
CLEAR:
	LEA BX,T1			;以T1为首地址，索引T2~T6
	MOV AL,11011111B	;从最高位，即最右端的数码管开始显示
	MOV SI,00H
	MOV CX,06H			;数码管显示，与实验八相同
	MC2:
		MOV DX,A8255
		OUT DX,AL
		SHR AL,1
		OR AL,10000000B	;逻辑右移，但是用1补全
		PUSH AX			;保存AX的值
			MOV DX,B8255
			MOV AL,[BX+SI]
			OUT DX,AL
		POP AX			;取出AX的值
		INC SI			;地址偏移自增
		CALL DELAY
	LOOP MC2
	RET
 
DELAY:
	PUSH BX
	MOV BX, 03FFH
	DEL:
		DEC BX
		JNZ DEL
	POP BX
	RET
CODE ENDS
	END START