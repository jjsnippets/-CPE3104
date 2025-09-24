; [submitted code from ceac1; code presented as is]

; TMC-1
; Arithmetic instructions. Create an assembly language program that lets
; the user input a value and determines whether that value is odd or even.


CR EQU 0DH      ; Carriage Return
LF EQU 0AH      ; Line Feed

.data
TEXT1 DB 'INPUT NUMBER: $'
EVEN_TX DB CR, LF, 'NUMBER IS EVEN!$'
ODD_TX DB CR, LF, 'NUMBER IS ODD!$'

.code
; Print out TEXT1
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H

; Single character input
    MOV AX, 0C01H       ; Clear buffer before accepting input    
    INT 21H             ; AL = 01H for echo

; Convert from ascii value to numeric value
    MOV AH, 0           ; AX contains user input
    SUB AL, '0'         ; Subtract ascii value '0'

; Divide user input by 2
    MOV BX, 02H
    DIV BL

; Check if modulo is 0
    MOV CL, 0H
    CMP AH, CL
    JZ prnt_even

; print_odd:
    MOV AH, 09H
    MOV DX, OFFSET ODD_TX
    INT 21H

    JMP term

prnt_even:
    MOV AH, 09H
    MOV DX, OFFSET EVEN_TX
    INT 21H

term:
    ; exit from program
    MOV AH, 4CH
    INT 21H
