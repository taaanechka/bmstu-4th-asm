EXTRN new_line: near
EXTRN space_print: near

EXTRN matrix_print: near

PUBLIC del_max_odd_str
PUBLIC find_max_odd_str

EXTRN n: byte
EXTRN m: byte
EXTRN matrix: byte
EXTRN odd_max: byte	
EXTRN i_max: byte
EXTRN InfoMatrixMsg: byte


SEGCODE SEGMENT PARA PUBLIC 'CODE'
    assume CS:SEGCODE
find_max_odd_str proc near
    mov ah, 2 ; для вывода количества нечетных элементов в строке
    mov bl, byte ptr[n]
    mov si, 0
	mov bh, 0
    
	;mov odd_max, 0
    row_for:
        mov cl, byte ptr[m]
		mov dh, 0
		;mov odd_cur, dh
		
        col_for:
            test byte ptr[matrix + si], 1
			jnz odd ; переходим на метку, если текущий элемент массива нечетный
			jz end_odd
			
			odd:
				;mov ah, 2
				;mov dl, byte ptr[matrix + si]
				;add dl, '0'
				;int 21h
				;
				;mov dl, " "
				;int 21h
				
				inc dh; увеличение счетчика
			end_odd:

            inc si

            loop col_for
			
		inc bh

		cmp byte ptr[odd_max], dh
		jl change_odd_max
		jnl end_change
		
		change_odd_max:
			mov odd_max, dh
			mov i_max, bh
			
		end_change:
		
        mov cl, bl
        dec bl
        loop row_for
		
		call new_line

    ret

find_max_odd_str endp

del_max_odd_str proc near
	mov bh, byte ptr[i_max]
	cmp bh, 0
	je end_for
	
	dec bh
	
	mov al, bh
	mul m
	mov si, ax

    lea  di, matrix[si]  ;Адрес области "куда".
	
	;mov dl, [di]
	;add dl, "0"
	;mov ah, 2
	;int 21h
	;
	;call space_print
	
	mov al, 1
	mul m
	add si, ax

	lea si, matrix[si]
	mov dl, [si]
	
	mov al, byte ptr[n]
	sub al, [i_max]
	
	mul m
	
	mov cx, ax
	jcxz end_del
	
	del_for:
		mov dh, [si]
		mov [di], dh
		
		;mov dl, [si]
		;add dl, "0"
		;mov ah, 2
		;int 21h
		
		;call space_print
		
		inc si
		inc di
    
		loop del_for
		
	end_del:
	dec [n]
	
	;mov dl, byte ptr[n]
	;add dl, "0"
	;mov ah, 2
	;int 21h
		
	end_for:

	;call matrix_print
			
	ret
del_max_odd_str endp

SEGCODE ENDS
END