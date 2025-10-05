; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE3-1 | Arithmetic Operations

; Activity #1

ORG 100H 

START: 
    MOV AL, 0F0H 
    MOV BL, 10H 
    ADD AL, BL 
    MOV CL, AL 
    SUB CL, BL 
    ADC CL, BL 
    MUL BL  
    MUL CX  
    IMUL BH 
    IMUL DX  
    DIV BL 
    DIV CX  
    IDIV BL  
    DIV CX
    
HLT