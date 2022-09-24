PUBLIC X
EXTRN input_X: far

STK SEGMENT PARA STACK 'STACK'
	db 100 dup(0)
STK ENDS

DSEG SEGMENT PARA PUBLIC 'DATA'
	X db ?
DSEG ENDS

CSEG SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG, DS:DSEG,  SS:STK
main:
	mov ax, DSEG
	mov ds, ax

	call input_X ; вызов функции ввода символа без эха

	; вывод символа из X на экран
	mov ah,02h
	mov dl, X
	int 21h

	mov ax, 4c00h
	int 21h
CSEG ENDS

END main