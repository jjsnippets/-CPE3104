; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/21
; LE3-2 | Logical Operations 

; Activity #2c

; Decimal byte to ascii byte

ORG 100H

.code
    MOV AX, 4           ; 0000_0100B
    OR AX, 0011_0000B   ; Add 030H: 0011_0000B = '0'    
                        ; Binary 4 -> ascii 4
                         
HLT    
