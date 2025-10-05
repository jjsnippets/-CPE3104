; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE3-1 | Arithmetic Operations

; Activity #2b

ORG 100H

.data
; Any byte value for Y, Z, W
; as long as the result is by 100
; (Assumed no remainder)
; and Z*W < 255
varY EQU 25
varZ EQU 25
varW EQU 3
res1 DB 0H      ; For Y = 25, Z = 25, W = 3
                ; Then Z = 1

.code
; Calculation 2
; X = (Y + Z * W) / 100
MOV AL, varZ    ; Load values of variables in registers
MOV BL, varW
MOV CL, varY
MOV DL, 100     ; constant 100 decimal in DX

MUL BL          ; Z * W
                ; Assumed that result is less than 0FFH
ADD AL, CL      ; (Z * W) + Y
DIV DL          ; ((Z * W)+ Y) / 100
                ; Final result is at AX

MOV BX, OFFSET res1
MOV [BX], AL    ; Save results at res1

; Terminate program
INT 20H
