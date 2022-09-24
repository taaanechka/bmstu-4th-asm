PUBLIC udec_print

EXTRN new_line: near
EXTRN numb:     word

SEGDATA SEGMENT PARA PUBLIC 'DATA'
    unsign_dec_msg  db "Unsigned decimal number:"
                    db 10, 13, "$"
SEGDATA ENDS

SEGCODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:SEGCODE, DS:SEGDATA
; вывод беззнакового десятичного числа из регистра AX на экран
udec_print  proc near
    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 09h
    mov     dx, offset unsign_dec_msg
    int     21h
    xor     ax, ax

    mov     bx, 10                      ; 10 - основание системы счисления (делитель)
    xor     cx, cx                      ; количество символов в модуле числа

    mov     ax, word ptr[numb]

    get_digit_udec:                     ; делим число на 10
            xor     dx, dx
            div     bx
            push    dx                  ; остаток сохраняем в стеке
            inc     cx                  ; количество цифр в числе
            or      ax, ax
            jnz     get_digit_udec      ; повторяем, пока в числе есть цифры

    mov     ah,     02h
    ud_symb_print:
            pop     dx                  ; извлекаем цифры (остатки от деления на 10) из стека
            add     dl, '0'             ; преобразуем в символы цифр
            int     21h                 ; выводим их на экран
    loop    ud_symb_print               

    call new_line

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret
udec_print  endp

SEGCODE ENDS
END