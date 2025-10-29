; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/10/29
; Laboratory Exercise #5 | I/O Interfacing (Address Decoding and I/O Ports)

; Write an assembly program that will create a running LED pattern
; (single cycle) on PORTA when the data IN PORTC is 01H. When the data
; IN PORTC is 02H, the 7-SEGMENT display IN PORTB will count from 0-9.
; Nothing will happen if the data IN PORTC is neither 01H OR 02H.
; Compile AND run the simulation.

ORG 100H
    PORTA EQU 0F0H                                      ; PORTA address 
    PORTB EQU 0F2H                                      ; PORTB address 
    PORTC EQU 0F4H                                      ; PORTC address  

.data
LEDARRAY DB 10000000B
SEVENDSP DB 0B
DIGITS DB 01111110B, 00110000B, 01101101B, 01111001B,   ; 0, 1, 2, 3
       DB 00110011B, 01011011B, 01011111B, 01110000B,   ; 4, 5, 6, 7
       DB 01111111B, 01111011B                          ; 8, 9

.code
MOV SI, OFFSET DIGITS

main_loop:
    CALL delay
    
    ; User input
    MOV DX, PORTC
    IN AL, DX
    
    ; If 01H, then running LED pattern
    CMP AL, 01H
    JE led_proc
    
    ; If 02H, then 7-segment display
    CMP AL, 02H
    JE ssg_proc 

    JMP main_loop
           
led_proc:
    ; LED pattern to be displayed
    ROR LEDARRAY, 1B    ; Change LED pattern        
    MOV AL, LEDARRAY
    
    ; Output to PORTA
    MOV DX, PORTA
    OUT DX, AL
    
    JMP main_loop
    
ssg_proc:
    ; Load to AL the digit to be displayed
    MOV BL, SEVENDSP
    MOV AL, [SI + BX]
    
    ; Output to PORTB
    MOV DX, PORTB
    OUT DX, AL
    
    ; Next digit 
    INC SEVENDSP
    
    ; SEVENDSP MOD 10 (without DIV)
    CMP SEVENDSP, 0AH
    JNE main_loop
    SUB SEVENDSP, 0AH
    JMP main_loop

; Artificial delay
delay:
    MOV BX, 031CAH
    lp_:
    DEC BX
    NOP
    JNZ lp_
    RET
