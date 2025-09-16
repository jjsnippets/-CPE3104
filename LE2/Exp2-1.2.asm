; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE2 | Addressing Modes

; Activity #2

ORG 100H  

; Skip data blocks
JMP _start                        

; 4 words of data  
WORDS DW 1234H, 5678H, 9ABCH, 0DEF0H  

; Start of instructions
_start:                     
    MOV BX, 02H             ; Let BX = 02H
    MOV DI, OFFSET WORDS    ; Memory address of WORDS = 0102H  
    MOV AX, [BX+DI+04H]     ; 02H + 0102H + 04H = 0108H
                            ; Address 0108H contains the last WORDS word: 0DEF0H
                            ; AX = 0DEF0H

INT 20H
