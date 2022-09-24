.model tiny
.code
.186
    org 100h ; Размер PSP (Префикс программного сегмента)
	
start:
old_out_time dd ?
sec db 0
speed db 1fh

; Init TSR
    jmp init

out_time_handler proc far
; Сохранить все в стеке
    pushf ; Поместить в стек значение регистра FLAGS
    pusha ; Поместить в стек значения всех 16-битных регистров общего назначения
    
; Получить время
    mov ah, 2
    int 1ah		; возвращает в cx:dx текущее число тиков таймера
    jc exit

; Проверить, новая ли секунда
    cmp sec, dh
    mov sec, dh
    je exit

; Если да, уменьшить скорость
    dec speed

; Изменение скорости 
    mov al, 0f3h 	; команда F3h отвечает за параметры режима автоповтора нажатой клавиши
					; Её байт данных имеет следующее значение:
					; 7 бит (старший) - всегда 0
					; 5,6 биты - пауза перед началом автоповтора (250, 500, 750 или 1000 мс)
					; 4-0 биты - скорость автоповтора (от 0000b (30 символов в секунду) до 11111b - 2
					; символа в секунду)
    out 60h, al
    xor al, al 		; 0 = 250ms, 20 = 500ms, 40 = 750ms, 60 = 1000ms
    or al, speed
    out 60h, al

; Если скорость не 0, перейти на метку exit
    cmp speed, 0
    jne exit

; Сбросить скорость
    mov speed, 1fh
 
; Восстановить все из стека
exit:
    popa ; Извлечь из стека значения всех 16-битных регистров общего назначения
    popf ; Извлечь из стека значение регистра FLAGS

    jmp cs:old_out_time

out_time_handler endp

; This inits TSR
init proc near
    mov ax, 351ch 	; AH = 35h, AL = номер прерывания int 21h - возвращает в es:bx адрес обработчика
    int 21h

    mov word ptr old_out_time, bx
    mov word ptr old_out_time + 2, es

    mov ax, 251ch 	; AH = 25h, AL = номер прерывания int 21h; ds:dx - адрес обработчика
    mov dx, offset out_time_handler
    int 21h

    mov dx, offset init ; количество байтов, которые следует оставить от начала PSP
    int 27h				; завершение программы с сохранением в памяти в DOS
init endp

end start
