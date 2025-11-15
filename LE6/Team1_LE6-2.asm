; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/13
; Laboratory Exercise #6 | Parallel I/O Devices Interfacing

; Activity #2
; Write a main program that will read the keypad data. Then on the
; middle of the LCD, display the key being pressed. The display 
; will only change when another key is pressed. 

ORG 100H

.data
    DATAB EQU 0F0H          ; Data bus of LCD
    CNTRL EQU 0F2H          ; LCD Control signals
                            ; ---- --x- E
                            ; ---- ---x RS       
    KYPAD EQU 0F4H          ; Numeric keypad (with 74C922)
                            ; xxxV DCBA where V is DAVBL
    COM_REG EQU 0F6H        ; 8255 Command Register
                            ; 10001 001 (89H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----1 --- Input for PORTC7-4
                            ; ----- 0-- Mode 1 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0

.code
    ; Program the 8255
    MOV DX, COM_REG
    MOV AL, 089H
    OUT DX, AL
    
    ; Set-up the LCD
    CALL INIT_LCD    
    
    MOV AL, '-'             ; Display a '-' to the LCD
    CALL DATA_CTRL    
        
    ; Wait until a button is pressed
wait_loop:
    MOV DX, KYPAD
    IN AL, DX
    
    TEST AL, 010H           ; If DAVBL is 1
    JZ wait_loop           ; then some button is pressed 
    
    AND AL, 0FH             ; Mask off high nibble
    
    ; Determine which button is pressed
    CMP AL, 00H
    JE DISP1
    
    CMP AL, 01H
    JE DISP2
    
    CMP AL, 02H
    JE DISP3
    
    CMP AL, 04H
    JE DISP4
    
    CMP AL, 05H
    JE DISP5
    
    CMP AL, 06H
    JE DISP6
    
    CMP AL, 08H
    JE DISP7
    
    CMP AL, 09H
    JE DISP8
    
    CMP AL, 0AH
    JE DISP9
    
    CMP AL, 0CH
    JE DISPD
    
    CMP AL, 0DH
    JE DISP0
    
    CMP AL, 0EH
    JE DISPD
    
    ; Display relevant key
    DISP1:  MOV AL, '1' 
    CALL DATA_CTRL
    JE wait_loop
    
    DISP2:  MOV AL, '2'
    CALL DATA_CTRL 
    JE wait_loop  
    
    DISP3:  MOV AL, '3' 
    CALL DATA_CTRL 
    JE wait_loop
    
    DISP4:  MOV AL, '4' 
    CALL DATA_CTRL 
    JE wait_loop 
    
    DISP5:  MOV AL, '5' 
    CALL DATA_CTRL 
    JE wait_loop
    
    DISP6:  MOV AL, '6' 
    CALL DATA_CTRL 
    JE wait_loop  
    
    DISP7:  MOV AL, '7' 
    CALL DATA_CTRL 
    JE wait_loop
    
    DISP8:  MOV AL, '8' 
    CALL DATA_CTRL 
    JE wait_loop 
    
    DISP9:  MOV AL, '9' 
    CALL DATA_CTRL 
    JE wait_loop
    
    DISP0:  MOV AL, '0' 
    CALL DATA_CTRL 
    JE wait_loop
    
    DISPD:  MOV AL, '-' 
    CALL DATA_CTRL 
    JE wait_loop
    
HLT    

; LCD Initialization function
INIT_LCD:
    CALL delay
      
    MOV AL, 038H            ; 0011 1000 (38H)
                            ; 001? ?0xx Function Set
                            ; ---1 ---- 8-bit data transfer
                            ; ---- 1--- Dual line display
    CALL INST_CTRL          ; ---- -0-- 5x8 Font size
        
    MOV AL, 08H             ; 0000 1000 (08H)
                            ; 0000 1??? Display ON/OFF
                            ; ---- -0-- Entire display off
                            ; ---- --0- Cursor off
    CALL INST_CTRL          ; ---- ---0 Cursor blinking off
    
    MOV AL, 01H             ; 0000 0001 (01H)
    CALL INST_CTRL          ; 0000 0001 Clear Display
    
    MOV AL, 06H             ; 0000 0110 (06H)
                            ; 0000 01?? Entry Mode Set
                            ; ---- --1- Increment / Move right
    CALL INST_CTRL          ; ---- ---0 No shifting
    
    MOV AL, 0CH             ; 0000 1100 (0CH)
                            ; 0000 1??? Display ON/OFF
                            ; ---- -1-- Entire display on
                            ; ---- --0- Cursor off
    CALL INST_CTRL          ; ---- ---0 Cursor blinking off
RET

; LCD 8-bit instruction function
; AX - Instruction to be moved (will be clobbered)
INST_CTRL:
    PUSH DX                 ; Housekeeping

    MOV DX, DATAB           ; Instruction to LCD data bus
    OUT DX, AL
    
    MOV DX, CNTRL           ; Set control pins
    MOV AL, 02H             ; Instruction Register
    OUT DX, AL              ; E = 1, RS = 0 
    
    CALL delay              ; Wait before next instruction
    
    MOV AL, 00H             ; Not leave E always HIGH
    OUT DX, AL
    
    POP DX                  ; Housekeeping
RET

; LCD 8-bit data function
; AX - Data to be moved (will be clobbered)
DATA_CTRL:
    PUSH DX                 ; Housekeeping
    PUSH AX
    
    ; Move cursor to center of screen
    MOV AL, 0CAH            ; 1100 1010 (CAH)
                            ; 1??? ???? DDRAM Address set
                            ; -100 1010 (4AH)   
    CALL INST_CTRL          ;           2nd line, 10th column
    
    POP AX    
    MOV DX, DATAB           ; To LCD data bus
    OUT DX, AL
    
    MOV DX, CNTRL           ; Set control pins
    MOV AL, 03H             ; Data Register
    OUT DX, AL              ; E = 1, RS = 1 

    CALL delay              ; Wait before next instruction
    
    MOV AL, 01H             ; Not leave E always HIGH
    OUT DX, AL
        
    POP DX                  ; Housekeeping
RET

; Artificial delay
; Should really check for BF (with interrupts)
delay:
    PUSH BX
    MOV BX, 00FAH
    lp_:
    DEC BX
    NOP
    JNZ lp_
    POP BX
RET