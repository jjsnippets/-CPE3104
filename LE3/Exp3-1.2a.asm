; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE3-1 | Arithmetic Operations

; Activity #2a

ORG 100H

.data
; Let A = 15, B = 5, D = 2, E = 1
varA EQU 15
varB EQU 5
varD EQU 2
varE EQU 1
res1 DB 0H

.code
; Calculation 1
; C = (B*D) + (A/B) - (A-B+E) = 2 
; B * D
MOV AL, varB    ; AX = 5
MOV BL, varD    ; BX = 2
MUL BL          ; 5 * 2 = 10
PUSH AX 

; A - B + E
MOV AL, varA    ; AX = 15
MOV BL, varB    ; BX = 5
MOV CL, varE    ; CX = 1
SUB AL, BL      ; 15 - 5 = 10
ADD AL, CL      ; 10 + 1 = 11
PUSH AX

; A / B
MOV AL, varA    ; AX = 15
                ; BX = 5 unchanged
DIV BL          ; 15 / 5 = 3
                ; AH = 0, AL = 3

; Final addition/subtraction in order of stack pops
; (A/B) - (A-B+E) + (B*D)  
POP BX         
SUB AL, BL      ; 3 - 11 = -8
POP BX
ADD AL, BL      ; -8 + 10 = 2
                ; Final result of 2 at AX

MOV BX, OFFSET res1
MOV [BX], AL    ; Save results at res1

; Terminate program
INT 20H
