EXTRN new_line: near
EXTRN space_print: near
EXTRN matrix_print: near
EXTRN find_max_odd_str: near
EXTRN del_max_odd_str: near

PUBLIC n
PUBLIC m
PUBLIC matrix
PUBLIC odd_max	
PUBLIC i_max
PUBLIC InfoMatrixMsg
PUBLIC ErrorNMsg

STK SEGMENT PARA STACK 'STACK'
    db 200 dup (0)
STK ENDS

SEGDATA SEGMENT PARA PUBLIC 'DATA'
	PromtDimensionMsg	db 'Enter matrix dimension (n m):', 0Dh, 0Ah, '$'
	PromptMatrixMsg		db 'Enter matrix:', 0Dh, 0Ah, '$'
	InfoMatrixMsg		db 'Result matrix:', 0Dh, 0Ah, '$'
	ErrorMsg			db 'Invalid input!', 0Dh, 0Ah, '$'
	ErrorNMsg			db 'No matrix elements!', '$'
	InfOddMsg			db 'Cur odd: ', '$'
	
    n             		db 1; строки
    m             		db 1; столбцы
	
	odd_max				db 0
    i_max				db 0

    matrix        		db 81 DUP ("0")
SEGDATA ENDS

SEGCODE SEGMENT PARA PUBLIC 'CODE'
    assume CS:SEGCODE, DS:SEGDATA, SS:STK
main:
    mov ax, SEGDATA
    mov ds, ax
	
	mov dx, offset PromtDimensionMsg ;DS:DX - адрес строки
	mov ah, 9 ;АН=09h выдать на дисплей строку
	int 21h

    mov ah, 1
    int 21h
	call is_size
    mov n, al
    sub n, "0"

    call space_print

    mov ah, 1
    int 21h
	call is_size
    mov m, al
    sub m, "0"
	
    call new_line
	
	mov dx, offset PromptMatrixMsg ;DS:DX - адрес строки
	mov ah, 9 ;АН=09h выдать на дисплей строку
	int 21h

    mov al, n
    mul m
    mov cx, ax

    mov si, 0
    read_matrix:
        mov ah, 1
        int 21h
		call is_digit
		sub al, '0'
        mov matrix[si], al
        inc si

        call space_print

        mov ax, si
        mov dh, byte ptr[m]
        div dh

        cmp ah, 0
        je call_new_line

        go_back:
        loop read_matrix

	call find_max_odd_str
    call del_max_odd_str
	
	mov dx, offset InfoMatrixMsg ;DS:DX - адрес строки
	mov ah, 9 ;АН=09h выдать на дисплей строку
	int 21h
	
    call matrix_print

    jmp exit

call_new_line:
    call new_line
    jmp go_back
	
is_digit proc near
	cmp		al, '0'
	jb      error_call
    cmp     al, '9'
    ja      error_call
	
    ret
is_digit endp

is_size proc near
	cmp		al, '1'
	jb      error_call
    cmp     al, '9'
    ja      error_call
	
    ret
is_size endp

error_lab proc near
		call new_line
		mov dx, offset ErrorMsg ;DS:DX - адрес строки
		mov ah, 9 ;АН=09h выдать на дисплей строку
		int 21h
		jmp exit
		
	ret
error_lab endp

error_call:
	call error_lab

exit:
	mov ax, 4c00h
    int 21h

SEGCODE ENDS
END main