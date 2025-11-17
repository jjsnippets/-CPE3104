; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/17
; Assignment | Interfacing Analog to Digital Converter (ADC0808)

; Write an assembly program that will read the data from the ADC AND
; display the voltage IN the 7-SEGMENT display. The 7-SEGMENT display
; IN PORTA will be the whole number while the one IN PORTB is the
; decimal (i.e., fractional part). When the input voltage is adjusted,
; the display will update IN real-time. For example, if the input
; voltage is 2.36 V then the display should be "2 3".
     
ORG 100H
    
.data
    P7_COM_REG  EQU 0FEH    ; Port 7 Command Register (8255)
    P7_PROGRAM  EQU 089H    ; 10001 001 (89H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----1 --- Input for PORTC7-4
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    SG_DISPLAY  EQU 0F8H    ; 7-segment displays in BCD Format
                            ; High Nibble - Whole number part
                            ; Low Nibble - Decimal number part
    CONTROL_SG  EQU 0FAH    ; Control signals for the ADC0808
                            ; -xxx -xxx
                            ; -x-- ---- OE                         
                            ; --x- ---- START
                            ; ---x ---- ALE
                            ; ---- -CBA Analog Channel Select
    ADC_OUTPUT  EQU 0FCH    ; ADC data lines
    
.code
; Set-up
    ; Program the 8255
    MOV DX, P7_COM_REG
    MOV AL, P7_PROGRAM
    OUT DX, AL
    
    ; Set 7-segments to be 0
    MOV DX, SG_DISPLAY
    MOV AL, 0
    OUT DX, AL

main_loop:
; Select first analog select
    MOV DX, CONTROL_SG
    MOV AL, 000H
    OUT DX, AL
    CALL delay
    
; ALE = 1
    MOV AL, 010H
    OUT DX, AL
    CALL delay

; START = 1
    MOV AL, 030H
    OUT DX, AL
    CALL delay
    
; OE = 1
    MOV AL, 040H
    OUT DX, AL
    CALL delay
    
; Read 8-bit data
    MOV DX, ADC_OUTPUT
    MOV AX, 0
    IN AL, DX
    
; Re-arranging formula (4) from datasheet to solve for Vin
;   N = (Vin - Vref+)/(Vref+ - Vref-) * 256
;   Assuming Vref+ = 5 and Vref- = 0, then
;   Vin = (N * 5)/256
    ; Whole number result         
    MOV BX, 5           ; Multiplication by 5
    MUL BL
    
    MOV DX, 0           ; Division by 256
    MOV BX, 256         ; AL - Whole number part (from 0 - 5)
    DIV BX              ; DL - Remainder (from 0 - 255) 

    MOV CH, AL          ; Whole number part for safe keeping

    ; First decimal number result (chopped off)
    MOV AL, DL          ; Transfer remainder to AL
    MOV BX, 10          ; Long division next step
    MUL BL
    
    MOV DX, 0
    MOV BX, 256         ; AL - Next decimal number (from 0 - 9)
    DIV BX
    
; Display digits
;   CH - Whole number part
;   AL - Decimal number part
        
    MOV CL, 4           ; Bit manipulations
    SHL CH, CL          ; CH = o0H   
    OR AL, CH           ; AL = odH
    
    MOV DX, SG_DISPLAY  ; To 7-segment displays
    OUT DX, AL
    
; Repeat forever
    JMP main_loop      
                     
HLT

; Artificial delay
delay:
    PUSH BX
    MOV BX, 0F00H
    lp_:
    DEC BX
    NOP
    JNZ lp_
    POP BX
RET
