; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/21
; LE3-2 | Logical Operations 

; Activity #2a

; Uppercase to lowercase

ORG 100H

.code
    MOV AH, 0
    MOV AL, 'B'         ; 0100_0010B
    OR AX, 0010_0000B   ; Bit 5 should be changed to 1    
                        ; For B: 0110_0010B = b 
HLT    
