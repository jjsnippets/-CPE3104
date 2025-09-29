; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/21
; LE3-2 | Logical Operations 

; Activity #2b

; Lowercase to uppercase

ORG 100H

.code
    MOV BH, 0
    MOV BL, 'y'         ; 0111_1001B
    AND BX, 1101_1111B  ; Bit 5 should be changed to 0    
                        ; For y: 0101_1001 = Y 
HLT    
