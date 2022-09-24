EXTRN ubin_read: near

EXTRN sbin_print: near
EXTRN ubin_print: near

EXTRN udec_print: near
EXTRN shex_print: near

PUBLIC new_line
PUBLIC numb

STK SEGMENT PARA STACK 'STACK'
    db 200 dup (?)
STK ENDS

SEGDATA SEGMENT PARA PUBLIC 'DATA'
    menu_prnt   db "1. Enter unsign binary number" 
                db 10, 13
                db "2. Print unsigned binary number"
                db 10, 13
                db "3. Print signed binary number" 
                db 10, 13
                db "4. Convert to unsigned decimal and print it" 
                db 10, 13
                db "5. Convert to signed hexadecimal and print it" 
                db 10, 13
                db "6. Exit" 
                db 10, 13
                db "Enter action: $"

    f_ptr       dw ubin_read, ubin_print, sbin_print, udec_print, shex_print, exit
    numb        dw 0
SEGDATA ENDS

SEGCODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:SEGCODE, DS:SEGDATA, SS:STK
main:
    mov ax, SEGDATA
    mov ds, ax

    menu:
        mov ah, 09h
        mov dx, offset menu_prnt 
        int 21h

        mov ah, 1
        int 21h

        mov ah, 0
        sub al, "1"     ; т.к. номера команд начинаются с 1, а индексация в массиве команд меню - с 0
        mov dl, 2       ; f_ptr[i] - 2 байта (dw)
        mul dl
        mov bx, ax      ; номер байта, с которого хранится функция

        call new_line
        call f_ptr[bx]  ; вызов выбранной команды
        call new_line
    jmp menu

new_line proc near
    push ax
    push dx

    mov ah, 2
    
    mov dl, 10
    int 21h

    mov dl, 13
    int 21h

    pop ax
    pop dx

    ret
new_line endp

exit proc near
    mov ax, 4c00h
    int 21h
exit endp

SEGCODE ENDS
END MAIN