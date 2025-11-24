;写规则字
CODE 	SEGMENT
		ASSUME	CS:CODE
START	PROC FAR
		MOV AX,8000H		;8000H作为段地址（调整数据寻址基准）
		MOV DS,AX		;立即数不能直接写入DS，需要分步
AA0:	MOV SI,0000H			;0000H作偏移地址
		MOV CX,0010H		;CX为LOOP指令的计数器，16个数
		MOV AX,0000H		;第一个数据0000H（2字节）
AA1:	MOV [SI],AX
		INC AX
		INC SI			;写两次是因为要移动两个字节
		INC SI
		LOOP AA1
		MOV AH,4CH		;中止
		INT 21H			;让操作系统结束程序
START 	ENDP
CODE 	ENDS
		END START