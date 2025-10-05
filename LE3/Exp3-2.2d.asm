; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/21
; LE3-2 | Logical Operations 

; Activity #2d

; Reverse case

CR EQU 0DH              ; Carriage Return
LF EQU 0AH              ; Line Feed

ORG 100H

.data
TEXT1 DB 'Enter letter to be manipulated: $'
TEXT2 DB CR, LF, 'Result: $'

.code
    ; Print out TEXT1
    MOV AX, 0900H
    MOV DX, OFFSET TEXT1
    INT 21H
    
    ; Accept single-character user input
    MOV AH, 01H
    INT 21H             ; AL = user input
    
    ; Reverse case
    XOR AL, 0010_0000B  ; Bit 5 determines if upper or lower case
    PUSH AX             ; For later printing
    
    ; Print out TEXT2
    MOV AX, 0900H
    MOV DX, OFFSET TEXT2
    INT 21H
    
    ; Print out toggled-case letter
    MOV AH, 02H
    POP DX              ; Print out XORed character
    INT 21H
                         
HLT    
