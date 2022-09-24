PUBLIC ubin_read
PUBLIC ubin_print
PUBLIC sbin_print

EXTRN new_line: near
EXTRN numb:     word

SEGDATA SEGMENT PARA PUBLIC 'DATA'
    error       db "Invalid binary number$"
    buff        db 17, 18 Dup("$")

    ent_msg     db "Enter unsigned binary number: $"
    ubin_msg    db "Unsigned binary number:"
                db 10, 13, "$"
    sbin_msg    db "Signed binary number:"
                db 10, 13, "$"
SEGDATA ENDS

SEGCODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:SEGCODE, DS:SEGDATA
; чтение беззнакового двоичного числа
ubin_read proc near
    push    ax
    push    dx
    mov     ah, 09h
    mov     dx, offset ent_msg
    int     21h
    pop     dx
    pop     ax

    mov     ah, 0ah
    xor     di, di
    mov     dx, offset buff     ; адрес буфера
    int     21h                 ; принимаем строку
    
    call new_line
    
; обрабатываем содержимое буфера
    mov     si, offset buff+2   ; берем адрес начала строки

    xor     ax, ax
	xor		cx, cx
    ;mov     bx, 2               ; основание сc
get_dig_ub:
    mov     cl, [si]            ; берем символ из буфера
    cmp     cl, 0dh             ; проверяем не последний ли он
    jz      get_numb
    
; если символ не последний, то проверяем его на правильность
    cmp     cl, '0'             ; если введен неверный символ <0
    jb      er
    cmp     cl, '1'             ; если введен неверный символ >1
    ja      er
 
    sub     cl, '0'             ; делаем из символа число 
    ;mul     bx                  ; умножаем на 2
	shl		ax, 1
    add     ax, cx              ; прибавляем к остальным
    inc     si                  ; указатель на следующий символ
    jmp     get_dig_ub          ; повторяем
 
; все символы из буфера обработаны число находится в ax
get_numb:
    mov   word ptr[numb], ax
ender:
    ret

er:                             ; если была ошибка, то выводим сообщение об этом и выходим
    mov     dx, offset error
    mov     ah, 09h
    int     21h
    jmp     ender
ubin_read endp

; вывод беззнакового двоичного числа из регистра BX на экран
ubin_print proc near
    push    ax
    push    dx
    mov     ah, 09h
    mov     dx, offset ubin_msg
    int     21h
    pop     dx
    pop     ax

    mov     bx, word ptr[numb]
    mov     cx, 16          ; количество цифр в числе
get_digit_ubin:
    shl     bx, 1           ; сдвиг влево, выставление флага cf (если старший бит = 1)
    jc      sf_ubin
    
    mov     dl, '0'
    jmp     ub_symb_print
    
sf_ubin:
    mov     dl, '1'
ub_symb_print:
    mov     ah, 02h
    int     21h             ; вывод символа
    loop    get_digit_ubin

    call new_line

    ret
    
ubin_print endp


; вывод знакового двоичного числа из регистра BX на экран
sbin_print proc near
    push    ax
    push    dx
    mov     ah, 09h
    mov     dx, offset sbin_msg
    int     21h
    pop     dx
    pop     ax

    mov     cx, 16          ; количество цифр в числе

    mov     bx, word ptr[numb]
    or      bx, bx          ; для отрицательного числа
    jns     get_digit_sbin	;psbin
    neg     bx              ; поменять знак (сделать положительным)
    push    ax
    mov     ah, 02h
    mov     dl, '-'
    int     21h             ; вывести на экран символ "-" (минус)
    pop     ax
;psbin:
;    mov     cx, 16          ; количество цифр в числе
get_digit_sbin:
    shl     bx, 1           ; сдвиг влево, выставление флага sf (если старший бит = 1)
    jc      sf_sbin
    
    mov     dl, '0'
    jmp     sb_symb_print
    
sf_sbin:
    mov     dl, '1'
sb_symb_print:
    mov     ah, 02h
    int     21h             ; вывод символа
    loop    get_digit_sbin
    
    call new_line

    ret
    
sbin_print endp

SEGCODE ENDS
END