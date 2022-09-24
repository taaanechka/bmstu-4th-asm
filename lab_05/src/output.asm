PUBLIC new_line
PUBLIC space_print
PUBLIC matrix_print

EXTRN n: byte
EXTRN m: byte
EXTRN matrix: byte
EXTRN ErrorNMsg: byte

SEGDATA SEGMENT PARA COMMON 'DATA'
SEGDATA ENDS


SEGCODE SEGMENT PARA PUBLIC 'CODE'
    assume CS:SEGCODE, DS:SEGDATA
	
new_line proc near
    mov ah, 2
	
    mov dl, 10
    int 21h
	
    mov dl, 13
    int 21h

    ret
new_line endp

matrix_print proc near
	cmp [n], 0
	je error_el_call
	
    mov ah, 2
    mov bl, byte ptr[n]
	;dec bl
    mov si, 0
    
    row_print:
        mov cl, byte ptr[m]
        col_print:
            mov dl, byte ptr[matrix + si]
			add dl, '0'
            inc si
            int 21h

            mov dl, " "
            int 21h
            loop col_print

        call new_line

        mov cl, bl
        dec bl
        mov ah, 2
        loop row_print

    ret

matrix_print endp

space_print proc near
    mov ah, 2
	
    mov dl, " "
    int 21h

    ret
space_print endp

error_msg proc near
	mov dx, offset ErrorNMsg ;DS:DX - адрес строки
	mov ah, 9 ;АН=09h выдать на дисплей строку
	int 21h
	
	mov ax, 4c00h
	int 21h
		
	ret
error_msg endp

error_el_call:
	call error_msg

SEGCODE ENDS
END