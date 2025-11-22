; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; T1-2 RTX 6090
; Ayabe, Kaishu; Fernandez, Schumacher Jaryl; Perez, Julio Miguel; Sarcol, Joshua
; Mini Simulation Project

; General comments on code:
;   NOP instructions indicate delay. They may be replaced by CALL DELAY if need be. 
;

; Case Study 2: Environment Sensor
; Being informed about the environment is important in our daily lives. Temperature,
; humidity and airpressure are key variables that affect the weather and our temper.
; The user can set a unit of measuring the temperature (Celsius or Fahrenheit) and
; pressure (atm or mb). The display updates in real-time to change in temperature,
; pressure and humidity.

; High level implementation
; Set-up:
;   Set-up the PPIs
;   Set-up the LCD to display default information
; 
; Temperature:
;   Grab data from temperature sensor
;   Determine from button if temperature to be displayed is in C or F
;   Manipulate data from ADC and convert if necessary
;   Display results to LCD screen
;
; Relative Humidity:
;   Grab data from relative humidity sensor
;   Manipulate data from ADC
;   Display results to LCD screen
;
; Atmospheric Pressure:
;   Grab data from atmospheric pressure sensor
;   Determine from button if pressure to be displayed is in atm or mb
;   Manipulate data from ADC and convert if necessary
;   Display results to LCD screen
;
; Repeat forever starting from Temperature

DATA    SEGMENT
    ORG 03000H    
    DELAY_TIME  EQU 0004AH  ; Software looping delay
    
    P6_COM_REG  EQU 076H    ; PORT6 Command Register (8255)
    P6_PROGRAM  EQU 080H    ; 10000 000 (80H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----0 --- Output for PORTC7-4 (unused)
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --0 Output for PORTC3-0
    
    LCD_DISPLAY EQU 070H    ; LCD display data bus                        
    LCD_CONTROL EQU 072H    ; LCD control lines
                            ; ---E ---R
                            ; ---E ---- E
                            ; ---- ---R RS
    
    LINE1       EQU 080H    ; LCD DDRAM Address locations
    LINE2       EQU 0C0H
    LINE3       EQU 094H
    LINE4       EQU 0D4H                                                                             
    
    LED_LIGHT   EQU 074H    ; "Hot" LED indicator
    
    
    P7_COM_REG  EQU 07EH    ; PORT7 Command Register (8255)
    P7_PROGRAM  EQU 099H    ; 10011 001 (99H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---1- --- Input for PORTA
                            ; ----1 --- Input for PORTC7-4 (unused)
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    
    ADC_DATA    EQU 078H    ; ADC data bus
    ADC_CONTROL EQU 07AH    ; ADC control lines
                            ; -OSL -CBA
                            ; -O-- ---- OE                         
                            ; --S- ---- START
                            ; ---L ---- ALE
                            ; ---- -CBA Analog Channel Select                     
    TEMP_SELECT EQU 000H    ; ---- -000 Temperature Sensor Select (LM35)
    HUMI_SELECT EQU 001H    ; ---- -001 Humidity Sensor Select (HIH-5030)
    PRES_SELECT EQU 002H    ; ---- -010 Atmospheric Sensor Select (MPX4115)
    
    BUTTON_DATA EQU 07CH    ; Unit switching buttons
                            ; ---- --PT
                            ; ---- --P- Atmospheric pressure toggle (atm / mb)
                            ; ---- ---T Temperature toggle (C / F)

    DISP1 DB " Outside Conditions "
    DISP2 DB "Temperature:        "
    DISP3 DB "Rel. Humid.:        "
    DISP4 DB "Atm. Press.:        "
                     
DATA    ENDS

STACK   SEGMENT PARA STACK
    DW 64 DUP(?)            ; Reserve 64 words for stack
TOS DW ?                    ; Top of stack marker
STACK   ENDS

; INTERRUPT HANDLERS HERE
;HANDLER0    SEGMENT
;ISR0    PROC FAR
;    ASSUME CS:HANDLER0, DS:DATA, SS:STACK
;    ORG 01000H    
; 
;ISR0    ENDP
;HANDLER0    ENDS

CODE    SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK
    ORG 08000H
START:
; Set-up
    ; Program PORT6
    MOV DX, P6_COM_REG
    MOV AL, P6_PROGRAM
    OUT DX, AL
    
    ; Program PORT7
    MOV DX, P7_COM_REG
    MOV AL, P7_PROGRAM
    OUT DX, AL
    
    ; Program the LCD
    CALL DELAY
      
    MOV AL, 038H            ; 0011 1000 (38H)
                            ; 001? ?0xx Function Set
                            ; ---1 ---- 8-bit data transfer
                            ; ---- 1--- Dual line display
    CALL LCD_INST           ; ---- -0-- 5x8 Font size
        
    MOV AL, 08H             ; 0000 1000 (08H)
                            ; 0000 1??? Display ON/OFF
                            ; ---- -0-- Entire display off
                            ; ---- --0- Cursor off
    CALL LCD_INST           ; ---- ---0 Cursor blinking off
    
    MOV AL, 01H             ; 0000 0001 (01H)
    CALL LCD_INST           ; 0000 0001 Clear Display
    
    MOV AL, 06H             ; 0000 0110 (06H)
                            ; 0000 01?? Entry Mode Set
                            ; ---- --1- Increment / Move right
    CALL LCD_INST           ; ---- ---0 No shifting
    
    MOV AL, 0CH             ; 0000 1100 (0CH)
                            ; 0000 1??? Display ON/OFF
                            ; ---- -1-- Entire display on
                            ; ---- --0- Cursor off
    CALL LCD_INST           ; ---- ---0 Cursor blinking off
    
    ; Preset display for the LCD
    MOV SI, OFFSET DISP1
    MOV DI, LINE1
    CALL LCD_LINE
    
    MOV SI, OFFSET DISP2
    MOV DI, LINE2
    CALL LCD_LINE     

    MOV SI, OFFSET DISP3
    MOV DI, LINE3
    CALL LCD_LINE
    
    MOV SI, OFFSET DISP4
    MOV DI, LINE4
    CALL LCD_LINE
    
     
HLT

; LCD 8-bit instruction transfer function
; AX << Instruction to be moved (will be clobbered)
LCD_INST:
    PUSH DX                 ; Housekeeping
    
    MOV DX, LCD_DISPLAY     ; Instruction to LCD data bus
    OUT DX, AL
    
    MOV DX, LCD_CONTROL     ; Set control pins
    MOV AL, 010H            ; Instruction Register
    OUT DX, AL              ; E = 1, RS = 0
    
    CALL DELAY              ; Wait before next instruction
    
    MOV AL, 000H            ; Not leave E always HIGH
    OUT DX, AL              ; E = 0, RS = 0
    
    POP DX                  ; Housekeeping
RET

; LCD 8-bit data transfer function
; AX << Data to be moved (will be clobbered)
LCD_DATA:
    PUSH DX                 ; Housekeeping    

    MOV DX, LCD_DISPLAY     ; Data to LCD data bus
    OUT DX, AL
    
    MOV DX, LCD_CONTROL     ; Set control pins
    MOV AL, 011H            ; Data Register
    OUT DX, AL              ; E = 1, RS = 1
    
    CALL DELAY              ; Wait before next instruction
    
    MOV AL, 001H            ; Not leave E always HIGH
    OUT DX, AL              ; E = 0, RS = 1
    
    POP DX                  ; Housekeeping
RET

; Helper function that prints 1 line (20 characters) into the LCD screen
; SI << Starting address of String (auto-increment)
; DI << Starting LCD DDRAM address
LCD_LINE:
    PUSH AX                 ; Housekeeping
    PUSH CX
    
    MOV AX, DI              ; Move cursor to starting position
    CALL LCD_INST
    
    MOV CX, 20              ; Print a total of 20 characters
    indiv_char:
        MOV AL, [SI]        ; Grab a character from SI
        CALL LCD_DATA       ; Display that character
        
        INC SI              ; Next character to be displayed
        LOOP indiv_char     ; Repeat 20 times
    
    POP CX                 ; Housekeeping
    POP AX
RET        

; ADC data request from an analog channel
; AX << Analog channel select (will be clobbered by output)
; AX >> 8-bit data from ADC
ADC_REQUEST:
    PUSH BX                 ; Housekeeping
    PUSH DX                 
                            ; Input integrity safeguard
    MOV BH, 00000111B       ; Bit-mask to only select the first 3 bits
    AND AL, BH              ; 0000 0CBA
    
    MOV DX, ADC_CONTROL     ; Select analog channel
    OUT DX, AL
    NOP
    
    MOV BL, 00010000B       ; ALE = 1 
    OR AL, BL               ; 0001 0CBA         
    OUT DX, AL
    NOP
    
    MOV BL, 00100000B       ; START = 1, ALE = 1
    OR AL, BL               ; 0011 0CBA
    OUT DX, AL              
    NOP                     
    
    AND AL, BH              ; OE = 1, START = 0, ALE = 0
    MOV BL, 01000000B       ; Note: SHL was not used as it would use CL
    OR AL, BL               ; 0100 0CBA
    OUT DX, AL
    NOP
    
    MOV DX, ADC_DATA        ; Read 8-bit data
    XOR AX, AX              ; Clear AX
    IN AL, DX
    
    POP BX                 ; Housekeeping
    POP DX
RET    

; Software delay loop
DELAY:
    PUSH CX
    MOV CX, DELAY_TIME
    _lp:
        NOP
        LOOP _lp
    POP CX
RET     
             
CODE    ENDS
        END START
 