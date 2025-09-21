; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/21
; LE3-2 | Logical Operations 

; Activity #1

ORG 100H

JMP START
ARR DB 01H,02H,03H,04H,05H 

START:
    MOV AX,00H 
    MOV CL,05H 
    MOV SI,00H 

BACK: 
    ADD AL, ARR[SI] 
    INC SI 
    DEC CL 
    JNZ BACK

    MOV BL,05H 
    DIV BL 

RET