; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/11
; LE1 | Using the EMU8086 Integrated Development Environment

; Activity #2-1

ORG 100H

MOV BX, 0123H 
MOV AX, 0456H 
ADD AX, BX 
SUB AX, BX
PUSH AX 
PUSH BX

RET
