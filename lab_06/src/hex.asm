PUBLIC shex_print

EXTRN new_line: near
EXTRN numb:     word

SEGDATA SEGMENT PARA PUBLIC 'DATA'
    sign_hex_msg    db "Signed hexadecimal number:"
                    db 10, 13, "$"
SEGDATA ENDS

SEGCODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:SEGCODE, DS:SEGDATA
; вывод знакового 16ричного числа из регистра AX на экран
shex_print proc near
    mov     ah, 09h
    mov     dx, offset sign_hex_msg
    int     21h
    xor     ax, ax

    mov     ax, word ptr[numb]

; выводим значение ax на консоль
    or      ax, ax          ; для отрицательного числа
    jns     pshex
    neg     ax              ; поменять знак (сделать положительным)
    push    ax              ; и вывести на экран символ "-" (минус)
    mov     ah, 02h
    mov     dl, '-'
    int     21h
    pop     ax

; количество цифр в cx
pshex:  
    xor     cx, cx
	;mov		bx, cx			; сохраняем значение счетчика
	;mov		cl, 4			; количество разрядов, на которое осуществится сдвиг (4, т.к. 16 сс)
    mov     bx, 16          ; основание сс
digit_shex:
    xor     dx, dx
    div     bx              ; делим число на основание сс; в остатке получается последняя цифра
    ;shr		dx, cl
	;mov		cx, dx
	;and		dl, 0xF0h
	;sub		cx, dx
	;mov		dx, cx
	push    dx              ; сразу выводить её нельзя, поэтому сохраним её в стэке
    ;mov		cx, bx
	inc     cx
; а с частным повторяем то же самое, отделяя от него очередную
; цифру справа, пока не останется ноль, что значит, что дальше
; слева только нули.
    test    ax, ax
    jnz     digit_shex

    mov     ah, 02h
get_digit_shex:
    pop     dx              ; извлекаем очередную цифру
    cmp     dl, 9
    jbe     sh_symb_print
    add     dl, 7           ; для нормального вывода чисел больше 9 в 16сс
sh_symb_print:
    add     dl, '0'         ; переводим цифру в символ
    int     21h             ; выводим

    loop    get_digit_shex  ; повторяем
    
    call new_line

    ret
 
shex_print endp

SEGCODE ENDS
END