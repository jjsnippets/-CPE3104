; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/10/29
; Laboratory Exercise #6 | Parallel I/O Devices Interfacing

; Activity #1
; Write an assembly program to display “HELLO!” in the middle of the second
; line of the LCD. Run the INIT_LCD function first before using the INST_CTRL
; AND DATA_CTRL procedures.

ORG 100H
    DATAB EQU 0F0H      ; Data bus of LCD
    CNTRL EQU 0F2H      ; LCD Control signals
                        ; ---- --x- E
                        ; ---- ---x RS       
    COM_REG EQU 0F6H    ; 8255 Command Register
                        ; 10000 000 (80H)
                        ; 1---- --- Command Group A
                        ; -00-- --- Mode 0 for PORTA
                        ; ---0- --- Output for PORTA
                        ; ----0 --- Output for PORTC7-4 (unused)
                        ; ----- 0-- Mode 1 for PORTB
                        ; ----- -0- Output for PORTB
                        ; ----- --0 Output for PORTC3-0 (unused)

.code
; Set-up
    MOV CX, 0
    
    ; Program the 8255
    MOV DX, COM_REG
    MOV AL, 080H
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

; LCD Initialization function
INIT_LCD:
    PUSH AX             ; Housekeeping
    
    MOV AL, 038H        ; 0011 1000 (38H)
                        ; 001? ?0xx Instruction code
                        ; ---1 ---- 8-bit data transfer
                        ; ---- 1--- Dual line display
                        ; ---- -0-- 5x8 Font size
    CALL INST_CTRL
    
    POP AX              ; Housekeeping
    RET

INST_CTRL:
    PUSH DX             ; Housekeeping
    
    
    
    POP DX              ; Housekeeping
    RET

DATA_CTRL:

RET