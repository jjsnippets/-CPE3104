; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/27
; LE3-6 | String Operations

ORG 100H 

JMP START 
STRING DB ‘THIS IS A SAMPLE STRING’, ‘$’ 

START:
    MOV AX, OFFSET STRING 
    MOV SI, AX 
    CALL REVERSE 
    ; LOAD ADDRESS OF THE STRING 
    LEA DX,STRING 
    MOV AH, 09H 
    INT 21H 
    MOV AH, 4CH 
    INT 21H 
    RET 

REVERSE:
    MOV CX, 0H     
    LOOP1: 
        MOV AL, [SI] 
        CMP AL, '$'
        JE LABEL1 
        PUSH [SI] 
        INC SI 
        INC CX 
        JMP LOOP1

LABEL1: 
    MOV SI, OFFSET STRING 

LOOP2: 
    CMP CX,0 
    JE EXIT 
    POP DX 
    XOR DH, DH 
    MOV [SI], DX 
    INC SI 
    DEC CX 
    JMP LOOP2 

EXIT: 
    MOV [SI], '$' 
    RET