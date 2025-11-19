; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/19
; Laboratory Exercise #7 | Hardware Interrupt Interfacing

; Activity #2
; In the foreground routine, write a program that will blink the LED IN
; PC7. For IR0 (keypad), write an ISR that will display the key pressed
; on the 7-SEGMENT display IN PORTA. The number will be latched until a
; new key is pressed. For IR1, display the same number displayed IN PORTA
; to the 7-SEGMENT display IN PORTB.   

DATA    SEGMENT
    ORG 03000H
    P6_COM_REG  EQU 0F6H    ; 8255 Command Register
    P6_PROGRAM  EQU 081H    ; 10000 001 (81H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----0 --- Output for PORTC7-4
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    ONE_DISPLAY EQU 0F0H    ; PORTA 7-segment display
    TWO_DISPLAY EQU 0F2H    ; PORTB 7-segment display
    KYPAD_INPUT EQU 0F4H    ; Keypad input (Lower nibble only)
    LED_OUTPUT  EQU 0F4H    ; LED output (MSB only)
    DEFAULT_SEG EQU 002H    ; Default 7-segment display character
    BLINK_DELAY EQU 07000H  ; Amount of cycles to delay per blink

    PIC0 EQU 0F8H           ; 8259 address when A1 = 0
                            ; 1111 1000      
    PIC1 EQU 0FAH           ; 8259 address when A1 = 1
                            ; 1111 1010      
    ICW1 EQU 013H           ; Initialization Command Word 1 (with PIC0)
                            ; 0001 0011 (13H)
                            ; ---1 ---- ICW1 with A0 = 0
                            ; xxx- ---- Does not apply to 8086 mode
                            ; ---- 0--- Edge triggered
                            ; ---- -0-- Call interval of 8
                            ; ---- --1- Single 8259
                            ; ---- ---1 ICW4 needed
    ICW2 EQU 080H           ; Initialization Command Word 2 (with PIC1)
                            ; 1000 0000 (80H)
                            ; 1000 0xxx 80H - 87H address range
    ICW4 EQU 003H           ; Initialization Command Word 2 (with PIC1)
                            ; 0000 0011 (03H)
                            ; 000- ---- IWC4 with A0 = 1
                            ; ---0 ---- Not nested
                            ; ---- 0x-- Non-buffered
                            ; ---- --1- Auto EOI
                            ; ---- ---1 8086 mode
    OCW1 EQU 0FCH           ; Operation Control Word 1 (with PIC1)
                            ; 1111 1100 (FCH)
                            ; 7654 3210 Only IR0 and IR1 are active
    VADD0 EQU 0200H         ; Interrupt vector address 0 (80H * 4 = 200H)
    VADD1 EQU 0204H         ; Interrupt vector address 1 (81H * 4 = 200H)
    
    ; Data to which segment to light up per number
    ; 0 to 9 then '-' (A)
    ; ABCD_EFGP
    DISP_SEGS DB 11111100B, 01100000B, 11011010B    ; 0 1 2
              DB 11110010B, 01100110B, 10110110B    ; 3 4 5
              DB 10111110B, 11100000B, 11111110B    ; 6 7 8
              DB 11110110B, 00000010B,              ; 9 -
    
    ; Variable holding the most recent button press
    SEG_STATE DB 0AH 
    
    ; Table that maps keypad presses to data
    ; Invalid states map to A
    KPD_TABLE DB 01H, 02H, 03H, 0AH, 04H, 05H, 06H, 0AH 
              DB 07H, 08H, 09H, 0AH, 0AH, 00H, 0AH, 0AH 
                             
DATA    ENDS

STACK   SEGMENT PARA STACK
    DW 64 DUP(?)            ; Reserve 64 words for stack
TOS DW ?                    ; Top of stack marker
STACK   ENDS

; Triggers when a key in the keypad is pressed
; Lights up the corresponding button to the first segment
HANDLER0    SEGMENT
ISR0    PROC FAR
    ASSUME CS:HANDLER0, DS:DATA, SS:STACK
    ORG 01000H    
    PUSHF                   ; Housekeeping
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
                            ; (Quick-fix)
    MOV DX, LED_OUTPUT      ; If before the interrupt the LED sets it to
    MOV AL, 0H              ; all 1's, then first set them to 0
    OUT DX, AL              ; LED_OUTPUT and KYPAD_INPUT share the same port
    
    MOV DX, KYPAD_INPUT     ; Grab data from keypad
    IN AL, DX  
    
    ; Determine which button is pressed
    XOR BX, BX              ; Data from encoder acts as an offset to
    MOV BL, AL              ; the tabe data
    
    MOV SI, OFFSET KPD_TABLE; BL now contains the corresponding button
    MOV BL, [SI + BX]       ; pressed in the keypad 
       
    MOV SEG_STATE, BL       ; Save value to variable
    
    MOV SI, OFFSET DISP_SEGS; Determine which segments to light up
    MOV AL, [SI + BX]
    
    MOV DX, ONE_DISPLAY     ; Display to the first segment
    OUT DX, AL
    
    POP SI                  ; Housekeeping                                   
    POP DX
    POP CX
    POP BX
    POP AX                    
    POPF
    IRET 
ISR0    ENDP
HANDLER0    ENDS

; Triggers when the button is pressed
; Copies the first segment to the second segment
HANDLER1    SEGMENT
ISR1    PROC FAR
    ASSUME CS:HANDLER1, DS:DATA, SS:STACK
    ORG 02000H    
    PUSHF                   ; Housekeeping
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    
    XOR BX, BX              
    MOV BL, SEG_STATE       ; Retrieve saved value
    
    MOV SI, OFFSET DISP_SEGS; Determine which segments to light up
    MOV AL, [SI + BX]                               
    
    MOV DX, TWO_DISPLAY     ; Display to the second segment
    OUT DX, AL    
    
    POP SI                  ; Housekeeping                                   
    POP DX
    POP BX
    POP AX                    
    POPF
    IRET 
ISR1    ENDP
HANDLER1    ENDS

CODE    SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK
    ORG 08000H
START:
; Set-up
    CLI                     ; Disable interrupts

    ; Load proper register values
    MOV AX, DATA            ; Data Segment      
    MOV DS, AX      
    MOV AX, STACK           ; Stack Segment     
    MOV SS, AX      
    LEA SP, TOS             ; Stack Pointer                              

    ; Program the 8255
    MOV DX, P6_COM_REG
    MOV AL, P6_PROGRAM
    OUT DX, AL
    
    ; Set 7-segment displays
    MOV DX, ONE_DISPLAY     ; First 7-segment display
    MOV AL, DEFAULT_SEG
    OUT DX, AL
    
    MOV DX, TWO_DISPLAY     ; Second 7-segment display
    MOV AL, DEFAULT_SEG
    OUT DX, AL     
    
    ; Program the 8259
    MOV DX, PIC0            ; ICW1
    MOV AL, ICW1
    OUT DX, AL
    
    MOV DX, PIC1            ; ICW2
    MOV AL, ICW2
    OUT DX, AL
    
    MOV AL, ICW4            ; ICW4
    OUT DX, AL
    
    MOV AL, OCW1            ; OCW1
    OUT DX, AL
    
    ; Store interrupt vectors to vector table
    XOR AX, AX              ; Set ES to 0
    MOV ES, AX
    
    MOV AX, OFFSET ISR0     ; Offset address of ISR0
    MOV [ES:VADD0], AX
    MOV AX, SEG ISR0        ; Segment address of ISR0
    MOV [ES:VADD0 + 2], AX   

    MOV AX, OFFSET ISR1     ; Offset address of ISR1
    MOV [ES:VADD1], AX
    MOV AX, SEG ISR1        ; Segment address of ISR1
    MOV [ES:VADD1 + 2], AX
    
    STI                     ; Enable interrupts      

; Foreground routine
    XOR BX, BX              ; Set BX to 0
    MOV DX, LED_OUTPUT      ; To LED
foreground:       
    MOV AL, BL              ; Display current state of BX                  
    OUT DX, AL
    
    MOV CX, BLINK_DELAY     ; Wait for some amount of time
    _delay:
        NOP
        LOOP _delay
    
    NOT BX                  ; Invert BX    
    
    JMP foreground          ; Repeat forever

HLT             
CODE    ENDS
        END START
