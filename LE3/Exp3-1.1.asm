; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE3-1 | Arithmetic Operations

; Activity #2

ORG 100H

.data
; Assume A = 15, B = 5, D = 2, E = 1
varA DB 15
varB DB 5
varD DB 2
varE DB 1

.code
; C = (B*D) + (A/B) - (A-B+E) = 2 
; B * D
MOV AL, varB
MOV BL, varD

MOV BX, varD
MUL BL
PUSH AX 

; A - B + E
MOV AX, 15
MOV CX, 
SUB AX, BX

; A / B
MOV AX, 15
MOV BL, 5
DIV BL
PUSH AX

INT 20H
