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
;   Determine from button if temperature to be displayed is in C or F
;   Grab data from temperature sensor
;   Decide if any of the LED indicators should be turned on or not
;   Manipulate data from ADC
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
    
    ; Constants    
    DELAY_TIME  EQU 00070H  ; Software looping delay
    
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
    
    LED_LIGHTS  EQU 074H    ; LED indicators
                            ; ---C ---H
                            ; ---C ---- COLD LED indicator
                            ; ---- ---H HOT LED indicator

    
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
                            ; ---P ---T
                            ; ---P ---- Atmospheric pressure toggle (atm / mb)
                            ; ---- ---T Temperature toggle (C / F)
    
    ; String definitions
    DISP1       DB " Outside Conditions "
    DISP1_L     EQU $ - DISP1
    DISP2       DB "Temp.:              "
    DISP2_L     EQU $ - DISP2
    DISP3       DB "Humi.:              "
    DISP3_L     EQU $ - DISP3
    DISP4       DB "Pres.:              "
    DISP4_L     EQU $ - DISP4
    
    UNIT_C      DB " dC     "
    UNIT_C_L    EQU $ - UNIT_C
    UNIT_F      DB " dF     "
    UNIT_F_L    EQU $ - UNIT_F
    UNIT_RH     DB "% RH   "
    UNIT_RH_L   EQU $ - UNIT_RH
    UNIT_ATM    DB " atm    "
    UNIT_ATM_L  EQU $ - UNIT_ATM
    UNIT_MB     DB " mb    "
    UNIT_MB_L   EQU $ - UNIT_MB

    ; Variables    
    TEMP_FF     DB 0        ; Holds the previous button states before polling 
    PRES_FF     DB 0        ; For software T flip-flop implementation (rising edge)
    
    TEMP_TOGGLE DB 0        ; 0 = Celsius   1 = Fahrenheit
    PRES_TOGGLE DB 0        ; 0 = atm       1 = mb
    
    TEMP_NEGATE DB 0        ; Workaround for IDIV not working as intended 
                     
DATA    ENDS

STACK   SEGMENT PARA STACK
    DW 64 DUP(?)            ; Reserve 64 words for stack
TOS DW ?                    ; Top of stack marker
STACK   ENDS

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
        
    MOV AL, 0CH             ; 0000 1100 (0CH)
                            ; 0000 1??? Display ON/OFF
                            ; ---- -1-- Entire display on
                            ; ---- --0- Cursor off
    CALL LCD_INST           ; ---- ---0 Cursor blinking off
    
    MOV AL, 01H             ; 0000 0001 (01H)
    CALL LCD_INST           ; 0000 0001 Clear Display
    
    MOV AL, 06H             ; 0000 0110 (06H)
                            ; 0000 01?? Entry Mode Set
                            ; ---- --1- Increment / Move right
    CALL LCD_INST           ; ---- ---0 No shifting
    
    ; Preset display for the LCD
    MOV SI, OFFSET DISP1
    MOV DI, LINE1
    MOV CX, DISP1_L
    CALL LCD_PRINT
    
    MOV SI, OFFSET DISP2
    MOV DI, LINE2
    MOV CX, DISP2_L
    CALL LCD_PRINT     

    MOV SI, OFFSET DISP3
    MOV DI, LINE3
    MOV CX, DISP3_L
    CALL LCD_PRINT
    
    MOV SI, OFFSET DISP4
    MOV DI, LINE4
    MOV CX, DISP4_L
    CALL LCD_PRINT

main_loop:
; Temperature
;   Determine from button if temperature to be displayed is in C or F
    MOV DX, BUTTON_DATA     ; Data from buttons
    XOR AX, AX
    IN AL, DX    
    AND AL, 01H             ; Only interested in bit 0
    
    CMP [TEMP_FF], 1        ; If the value at TEMP_FF is 1
    JE temp_held            ; Then the button "was" held    
                            ; Otherwise, it was in the released state
    
    CMP AL, 1               ; If the current state is then 1
    JNE temp_button_end     ; Then it indicates a rising edge
    
    NOT TEMP_TOGGLE         ; Rising edge, so toggle the output
    MOV TEMP_FF, 1          ; Finished rising edge logic
    JMP temp_button_end
    
    temp_held:
    CMP AL, 0                   ; If the current state is then 0
    JNE temp_button_end         ; Then it indicates a falling edge
    
    MOV TEMP_FF, 0              ; Finished falling edge logic
    
    temp_button_end:    
;   Grab data from temperature sensor
    MOV AX, TEMP_SELECT     
    CALL ADC_REQUEST
       
;   Decide if any of the LED indicators should be turned on or not
    ; Implement PAGASA Heat Index Chart indicators
    ; To be implemented last

;   Manipulate data from ADC
    MOV TEMP_NEGATE, 0          ; Zero out the negative indicator
    CMP [TEMP_TOGGLE], 0        ; If current state is 0, then value to calculate is in Celsius
    JNE calc_fah                ; Otherwise, it is in Fahrenheit
    
    ; calc_cel:
        MOV BX, 165
        MOV CX, -11750
        MOV DI, 236    
        CALL CALC_SENSOR        ; y = (165x - 11750)/236 for -40C to 125C
        
        MOV SI, OFFSET UNIT_C   ; Display C in LCD
        MOV CX, UNIT_C_L          
    JMP temp_disp
    
    calc_fah:
        MOV BX, 297
        MOV CX, -13598
        MOV DI, 236    
        CALL CALC_SENSOR        ; y = (297x - 13598)/236 for -40F to 257F
        
        MOV SI, OFFSET UNIT_F   ; Display F in LCD
        MOV CX, UNIT_F_L    
       
;   Display results to LCD screen
    temp_disp:
    MOV DI, LINE2 + 7           ; Position in LCD
    
    TEST [TEMP_NEGATE], 1       ; Check if temperature is negative
    JZ not_negative
    
    ; is_negative:       
        PUSH AX                 ; Save number
        
        MOV AX, DI              ; Move cursor to starting position
        CALL LCD_INST
        INC DI                  ; To next position
        
        MOV AL, "-"             ; Display the negative sign
        CALL LCD_DATA
        
        POP AX                  ; Retrieve number
    
    not_negative:    
    CALL LCD_RESULT    

; Relative Humidity
    ; Grab data from relative humidity sensor
    MOV AX, HUMI_SELECT     
    CALL ADC_REQUEST
    
    ; Manipulate data from ADC
    MOV BX, 100
    MOV CX, -4800
    MOV DI, 203    
    CALL CALC_SENSOR        ; y = (100x - 4800)/203

    ; Display results to LCD screen
    MOV SI, OFFSET UNIT_RH
    MOV DI, LINE3 + 7
    MOV CX, UNIT_RH_L
    CALL LCD_RESULT

    JMP main_loop
  
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

; Helper function that prints CX characters into the LCD screen
; SI << Starting address of String (auto-increment)
; DI << Starting LCD DDRAM address
; CX << Number of characters to print
LCD_PRINT:
    PUSH AX                 ; Housekeeping
    
    MOV AX, DI              ; Move cursor to starting position
    CALL LCD_INST
    
    indiv_char:
        MOV AL, [SI]        ; Grab a character from SI
        CALL LCD_DATA       ; Display that character
        
        INC SI              ; Next character to be displayed
        LOOP indiv_char     ; Repeat 20 times
    
    POP AX                 ; Housekeeping
RET
        
; Displays a number to the LCD screen
; AX << The number to be displayed (positive only)
; CX << Length of the string found in CX
; SI << The string address of the unit to be displayed (auto increment)
; DI << Starting LCD DDRAM address
LCD_RESULT:
    PUSH BX
    PUSH DX                 ; Housekeeping

; Set-up
    PUSH CX                 ; Save the string length    
    PUSH AX                 ; Save the number to be displayed
    
    MOV AX, DI              ; Move cursor to starting position
    CALL LCD_INST 
    
    POP AX                  ; Retrieve AX from stack
    MOV BL, 10              ; Division by 10    
    XOR CX, CX              ; Counter for amount of numbers to display
    XOR DX, DX              ; Temporary register used to push to/pop from stack
    
    ; Special case
    ; If the number to be displayed is 0
        CMP AX, 0           ; If not zero
        JNE div_loop        ; Then go to normal case
    
        PUSH AX             ; Otherwise, push the 0 value
        INC CX              ; Length of the number is 1
        JMP _exit_div       ; Proceed to displaying the number
    
    ; Normal case
    ; If the number to be displayed is not 0
    div_loop:      
        DIV BL              ; AL = whole number result
                            ; AH = remainder
                            
        MOV DL, AH          ; Copy remainder to DX
        PUSH DX             ; Push to stack
        INC CX              ; Increment number length counter
        
        XOR AH, AH          ; Clear AH for proper re-division

        CMP AX, 0           ; If the number to be divided is 0
        JE _exit_div        ; Then end the division loop    
    JMP div_loop            ; Otherwise, repeat division loop
    
    _exit_div:
    ADD DI, CX

; Display the number
    print_loop:                            
        POP AX              ; Retrieve number to be displayed from stack
        OR AL, 030H         ; ASCII Conversion
        CALL LCD_DATA       ; Display to LCD
    
    LOOP print_loop         ; If there are no numbers to print
                            ; Then proceed to displaying the unit             

; Display the unit    
    POP CX                  ; Retrieve CX from stack    
                            ; SI untouched
                            ; DI = DI + CX right after the division loop
    CALL LCD_PRINT          ; Display the unit                             
    
    POP DX                  ; Housekeeping
    POP BX    
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
    CALL DELAY
    
    MOV BL, 00010000B       ; ALE = 1 
    OR AL, BL               ; 0001 0CBA         
    OUT DX, AL
    CALL DELAY
    
    MOV BL, 00100000B       ; START = 1, ALE = 1
    OR AL, BL               ; 0011 0CBA
    OUT DX, AL              
    CALL DELAY                     
    
    AND AL, BH              ; OE = 1, START = 0, ALE = 0
    MOV BL, 01000000B       ; Note: SHL was not used as it would use CL
    OR AL, BL               ; 0100 0CBA
    OUT DX, AL
    CALL DELAY
    
    MOV DX, ADC_DATA        ; Read 8-bit data
    XOR AX, AX              ; Clear AX
    IN AL, DX
    
    POP DX                  ; Housekeeping
    POP BX
RET

; Calculates the linear equation y = (ax + b)/c
; 
; Converts the 0 - 255 output x of the ADC to the real-world sensor value y
;   y = (165x - 11750)/236 for -40C to 125C
;   y = (297x - 13598)/236 for -40F to 257F
;   y = (100x - 4800)/203 for 0% to 100% relative humidity
;   y = (986x + 20088)/229 for 148 milli-atm to 1134 milli-atm
;   y = (1000x + 20350)/229 for 150 millibar to 1150 millibar
; 
; AX << Input from the ADC
; BX << Multiplier
; CX << Signed constant
; DI << Divisor
; 
; AX >> Signed result
; DX >> Remainder after division (unused)
CALC_SENSOR:
; Multiplication AX * BX = (DX AX)
    XOR AH, AH              ; Clear AH and flags
    XOR DX, DX
    MUL BX                  ; Result is 32-bit, split across (DX AX)
    
; Addition (DX AX) + CX = (DX AX)
    ; Assuming that CX is positive
    ADD AX, CX              ; Low word addition
    ADC DX, 0               ; Add carry to high word
    
    ; Negative CX correction
    CMP CX, 0               
    JGE _not_negative       ; If CX is positive, then no need to correct result
    DEC DX                  ; Otherwise, subtract 1 from high word    
    _not_negative:          ; Basically sign extending CX to 32-bit
    
    ; Negative Temperature workaround
    ;   As it seems that IDIV DI when (DX AX) is negative throws an interrupt rather than dividing 
    TEST DX, 08000H         ; Check if DX is negative
    JZ _normal_div                                    
                            ; AX is sufficient as largest negative value would be
                            ; 165 * 14 - 11750 = -9440, which will fit in a single register
    
    MOV TEMP_NEGATE, 1      ; Set the negative indicator                         
    NEG AX                  ; Change sign of AX to positive                           
    XOR DX, DX              ; Clear DX
            
    _normal_div:
; Division (DX AX) / DI = AX
    DIV DI                  ; Unsigned divide.
                            ; Whole number result in AX, Remainder in DX

; 0.5 round-up
    PUSH AX                 ; Save whole number result
    
    MOV AX, DI              ; Transfer divisor to AX 
    MOV CX, 2               ; Determine half of the divisor    
    DIV CL                  ; AL = half of DI       AH = remainder (0 or 1)    
    XOR AH, AH              ; Clear AH

    CMP DX, AX              ; If the fractional part is at least half
    JB _keep_same           ; Then round up
    
    ; _round_up
    POP AX
    INC AX                  ; Add 1 to final result
    RET    
   
   _keep_same:
   POP AX                   ; otherwise keep it the same
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
 