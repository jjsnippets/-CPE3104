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

.data
STRNG DB "HELLO!"
LEN EQU $ - STRNG    
    
.code
    ; Program the 8255
    MOV DX, COM_REG
    MOV AL, 080H
    OUT DX, AL
    
    ; Set-up the LCD
    CALL INIT_LCD
      
    ; Move cursor to desired location
    MOV AL, 0C7H            ; 1100 0111 (C8H)
                            ; 1??? ???? DDRAM Address set
                            ; -100 0111 (48H)   
    CALL INST_CTRL          ;           2nd line, 8th column
    
    ; Display string
    MOV BX, 0               ; Counter
    MOV SI, OFFSET STRNG    ; Address of the string to print
    
    disp_str:
        MOV AL, [SI + BX]   ; Current character to print
        CALL DATA_CTRL
        
        INC BX              ; Next character to print
        
        CMP BX, LEN + 1     ; Repeat LEN times
        JNE disp_str        
    
HLT    

; LCD Initialization function
INIT_LCD:
    CALL delay
      
    MOV AL, 038H        ; 0011 1000 (38H)
                        ; 001? ?0xx Function Set
                        ; ---1 ---- 8-bit data transfer
                        ; ---- 1--- Dual line display
    CALL INST_CTRL      ; ---- -0-- 5x8 Font size
        
    MOV AL, 08H         ; 0000 1000 (08H)
                        ; 0000 1??? Display ON/OFF
                        ; ---- -0-- Entire display off
                        ; ---- --0- Cursor off
    CALL INST_CTRL      ; ---- ---0 Cursor blinking off
    
    MOV AL, 01H         ; 0000 0001 (01H)
    CALL INST_CTRL      ; 0000 0001 Clear Display
    
    MOV AL, 06H         ; 0000 0110 (06H)
                        ; 0000 01?? Entry Mode Set
                        ; ---- --1- Increment / Move right
    CALL INST_CTRL      ; ---- ---0 No shifting
    
    MOV AL, 0CH         ; 0000 1100 (0CH)
                        ; 0000 1??? Display ON/OFF
                        ; ---- -1-- Entire display on
                        ; ---- --0- Cursor off
    CALL INST_CTRL      ; ---- ---0 Cursor blinking off
RET

; LCD 8-bit instruction function
; AX - Instruction to be moved (will be clobbered)
INST_CTRL:
    PUSH DX             ; Housekeeping
    
    MOV DX, DATAB       ; Instruction to LCD data bus
    OUT DX, AL
    
    MOV DX, CNTRL       ; Set control pins
    MOV AL, 02H         ; Instruction Register
    OUT DX, AL          ; E = 1, RS = 0 
    
    CALL delay          ; Wait before next instruction
    
    MOV AL, 00H         ; Not leave E always HIGH
    OUT DX, AL
    
    POP DX              ; Housekeeping
RET

; LCD 8-bit data function
; AX - Data to be moved (will be clobbered)
DATA_CTRL:
    PUSH DX             ; Housekeeping
    
    MOV DX, DATAB       ; To LCD data bus
    OUT DX, AL
    
    MOV DX, CNTRL       ; Set control pins
    MOV AL, 03H         ; Data Register
    OUT DX, AL          ; E = 1, RS = 1 

    CALL delay          ; Wait before next instruction
    
    MOV AL, 01H         ; Not leave E always HIGH
    OUT DX, AL
        
    POP DX              ; Housekeeping
RET

; Artificial delay
; Should really check for BF (with interrupts)
delay:
    PUSH BX
    MOV BX, 0ACAH
    lp_:
    DEC BX
    NOP
    JNZ lp_
    POP BX
RET