; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/17
; Laboratory Exercise #6 | Parallel I/O Devices Interfacing

; Activity #3
; A computer system with an LCD and numeric keypad controls a soft drink
; dispenser (via logic signals represented by 4 LEDs). The dispenser has
; two (2) types of beverage AND each has two (2) cup sizes. When the system
; starts, the choices will be displayed then waits for user input.
;
; After the user inputs the choice (1-4), the corresponding LED will turn
; ON for the given duration then the LCD will display a status. After the
; time duration, the LED turns OFF AND the display will go back to the beverage
; menu AND waits for user input.

; High Level Implementation
;   Display menu
;   Wait until user chooses a valid option
;   Hold relevant LED and display status for some amount of time
;   Repeat forever   

ORG 100H

.data
    P0_COM_REG  EQU 0C6H    ; Port 0 Command Register (8252)
    P0_PROGRAM  EQU 038H    ; 00_11_100_0 (038H)
                            ; 00 -- --- - Clock 0
                            ; -- 11 --- - Read/Write from LSB, then MSB
                            ; -- -- 100 - Mode 4
                            ; -- -- --- - Binary
    TIMER_PORT  EQU 0C0H    ; Counter 0
    MSB_DELAY   EQU 00FH    ; 4000Hz (0FA0H) 
    LSB_DELAY   EQU 0A0H         

    P6_COM_REG  EQU 0F6H    ; Port 6 Command Register (8255)
    P6_PROGRAM  EQU 089H    ; 10001 001 (89H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----1 --- Input for PORTC7-4
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    DATAB       EQU 0F0H    ; Data bus of LCD
    CNTRL       EQU 0F2H    ; LCD Control signals
                            ; ---- --x- E
                            ; ---- ---x RS       
    KYPAD       EQU 0F4H    ; Numeric keypad (with 74C922)
                            ; xxxV DCBA where V is DAVBL

    P7_COM_REG  EQU 0FEH    ; Port 7 Command Register (8255)
    P7_PROGRAM  EQU 082H    ; 10000 010 (82H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----0 --- Output for PORTC7-4 (unused)
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -1- Input for PORTB
                            ; ----- --0 Output for PORTC3-0 (unused)
    LED_CNTRL   EQU 0F8H    ; LED Display (Lower nibble only)
    SIGNAL_PORT EQU 0FAH    ; 8253 signal output
    
    LINE1_LOC   EQU 080H    ; LCD DDRAM Address locations
    LINE2_LOC   EQU 0C0H
    LINE3_LOC   EQU 094H
    LINE4_LOC   EQU 0D4H                                       
    
LINE1_MENU DB "[1] Coke Large      "
LINE2_MENU DB "[2] Coke Medium     "
LINE3_MENU DB "[3] Sprite Large    "
LINE4_MENU DB "[4] Sprite Medium   "
DISP1_MENU DB "   Dispensing...    "
DISP2_MENU DB "        x S         "          
 
.code
; Set-up
    ; Program PORT0
    MOV DX, P0_COM_REG
    MOV AL, P0_PROGRAM
    OUT DX, AL
    
    ; Program PORT6
    MOV DX, P6_COM_REG
    MOV AL, P6_PROGRAM
    OUT DX, AL
    
    ; Program PORT7
    MOV DX, P7_COM_REG
    MOV AL, P7_PROGRAM
    OUT DX, AL
    
    ; Program the LCD
    CALL INIT_LCD

; Display menu  
main_menu:
    MOV SI, OFFSET LINE1_MENU
    MOV DI, LINE1_LOC
    CALL LINE_DISP
    
    MOV SI, OFFSET LINE2_MENU
    MOV DI, LINE2_LOC
    CALL LINE_DISP

    MOV SI, OFFSET LINE3_MENU
    MOV DI, LINE3_LOC
    CALL LINE_DISP
    
    MOV SI, OFFSET LINE4_MENU
    MOV DI, LINE4_LOC
    CALL LINE_DISP    

; Wait until user chooses a valid option
poll_loop:
    MOV DX, KYPAD
    IN AL, DX
    
    TEST AL, 010H       ; If DAVBL is 1
    JZ poll_loop        ; Then some button is pressed
    
    AND AL, 0FH         ; Mask off high nibble
    
    CMP AL, 00H         ; Line 1 option
    JE opt1
    
    CMP AL, 01H         ; Line 2 option
    JE opt2
    
    CMP AL, 02H         ; Line 3 option
    JE opt3
    
    CMP AL, 04H         ; Line 4 option
    JE opt4
    
    JMP poll_loop       ; Otherwise, invalid option

; Hold relevant LED and display status for some amount of time
; AL - LED to light up
; CX - Number of seconds to wait
opt1:
    MOV AL, 01H
    MOV CX, 07H
    JMP disp_screen

opt2:
    MOV AL, 02H
    MOV CX, 04H
    JMP disp_screen    
     
opt3:
    MOV AL, 04H
    MOV CX, 07H
    JMP disp_screen

opt4:
    MOV AL, 08H
    MOV CX, 04H
    JMP disp_screen    

disp_screen:
    ; Light up specified LED
    MOV DX, LED_CNTRL
    OUT DX, AL

    ; Clear screen
    MOV AL, 01H                 
    CALL INST_CTRL
    
    ; Display dispensing screen 
    MOV SI, OFFSET DISP1_MENU
    MOV DI, LINE2_LOC
    CALL LINE_DISP
    
    MOV SI, OFFSET DISP2_MENU
    MOV DI, LINE3_LOC
    CALL LINE_DISP
    
    ; Wait for CX seconds
    wait_loop:
        ; Overwrite current seconds character
        MOV AL, LINE3_LOC + 8
        CALL INST_CTRL
        
        ; Display the current time to wait
        MOV AL, CL
        ADD AL, '0'
        CALL DATA_CTRL
        
        ; Load the time to wait
        MOV DX, TIMER_PORT
        MOV AL, LSB_DELAY
        OUT DX, AL
        
        MOV AL, MSB_DELAY
        OUT DX, AL
        
        ; Wait for 1 second
        _sec:
            MOV DX, SIGNAL_PORT
            IN AL, DX
            
            CMP AL, 0
            JNZ _sec     
        
        ; Repeat CX times
        LOOP wait_loop      
        
; Repeat forever
    ; Turn off LED
    MOV DX, LED_CNTRL
    MOV AL, 00H
    OUT DX, AL   

    JMP main_menu           
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

; LCD Line Display
; SI - Starting Address of String (auto-increment)
; DI - Starting LCD DDRAM Address
LINE_DISP:
    PUSH AX                 ; Housekeeping
    PUSH CX
    
    MOV AX, DI              ; Move cursor to start of line
    CALL INST_CTRL
                 
    MOV CX, 20              ; Print 20 characters in total          
    indiv_char:
        MOV AL, [SI]        ; Print a single character
        CALL DATA_CTRL
        
        INC SI              ; Next character to print
        LOOP indiv_char
  
    POP CX                  ; Housekeeping
    POP AX
RET 

; Artificial delay
; Should really check for BF (with interrupts)
delay:
    PUSH BX
    MOV BX, 004AH
    lp_:
    DEC BX
    NOP
    JNZ lp_
    POP BX
RET