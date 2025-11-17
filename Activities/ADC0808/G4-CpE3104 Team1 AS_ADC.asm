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
    P7_COM_REG  EQU 0F6H    ; Port 7 Command Register (8255)
    P7_PROGRAM  EQU 089H    ; 10001 001 (89H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----1 --- Input for PORTC7-4
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    SG_DISPLAY  EQU 0F0H    ; 7-segment displays in BCD Format
                            ; High Nibble - Whole number part
                            ; Low Nibble - Decimal number part
    CONTROL_SG  EQU 0F2H    ; Control signals for the ADC0808
                            ; -xxx -xxx
                            ; -x-- ---- OE                         
                            ; --x- ---- START
                            ; ---x ---- ALE
                            ; ---- -CBA Analog Channel Select
    AD_OUTPUT  EQU 0F4H     ; ADC data lines
    
.code
; Set-up
    ; Program the 8255
    MOV DX, P7_COM_REG
    MOV AL, P7_PROGRAM
    OUT DX, AL
    
    ; Set 7-segments to be 0
    MOV DX, SG_DISPLAY
    MOV AL, 0H
    OUT DX, AL
    
HLT
