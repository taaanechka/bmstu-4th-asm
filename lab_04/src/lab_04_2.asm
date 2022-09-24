PUBLIC input_X
EXTRN X: byte

CSEG SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG;, ES:DS2

input_X proc far

	mov ah, 08h
	int 21h
	mov X, al

	ret
input_X endp

CSEG ENDS
END