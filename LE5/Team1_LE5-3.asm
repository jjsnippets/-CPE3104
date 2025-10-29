; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/10/29
; Laboratory Exercise #5 | I/O Interfacing (Address Decoding and I/O Ports)

; Write an assembly program to increment the two-digit counter (PORTB &
; PORTA) when the switch IN PORTC is pressed. Upon reset, the value of
; the counter is “00”. When the counter reaches “99”, it reverts back
; to “00” on the next increment. Apply a simple (10 ms delay) software
; switch debouncing to make it function properly. 

; High level approach
;   If button is pressed, increment counter by 1
;   If counter == 100, then reset to 0
;   Display digits
;   Repeat forever

ORG 100H
    PORTA EQU 0F0H      ; PORTA address (LSD) 
    PORTB EQU 0F2H      ; PORTB address (MSD)
    PORTC EQU 0F4H      ; PORTC address (Push button)
    COM_REG EQU 0F6H    ; Command Register Address  

.code
; Set-up
    MOV CX, 0
    
    ; Program the 8255
    MOV DX, COM_REG
    MOV AL, 089H
    OUT DX, AL
    
    ; Display digits to 0
    MOV AL, 0H
    MOV DX, PORTA       ; LSD
    OUT DX, AL    
    MOV DX, PORTB       ; MSD
    OUT DX, AL
    
main_loop:
    CALL delay
    
; If button is pressed, increment counter by 1
    MOV DX, PORTC
    IN AL, DX
    
    CMP AL, 01H
    JNE main_loop
    INC CX
    
; If counter == 100, then reset to 0
    CMP CX, 100
    JNE skip_reset
    MOV CX, 0H
    skip_reset:
    
; Display digits
    MOV AX, CX
    MOV BL, 10          ; AH = ones, AL = tens
    DIV BL              ; Digits in AX now 7-segment compatible                 

    ; Display MSD    
    MOV DX, PORTB
    OUT DX, AL          

    ; Display LSD    
    MOV AL, AH
    MOV DX, PORTA
    OUT DX, AL

; Repeat forever     
    JMP main_loop

; Artificial delay
delay:
    MOV BX, 0ACAH
    lp_:
    DEC BX
    NOP
    JNZ lp_
    RET
