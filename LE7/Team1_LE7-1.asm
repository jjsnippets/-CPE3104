; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/18
; Laboratory Exercise #7 | Hardware Interrupt Interfacing

; Activity #1
; ISR0 will display '9' on the 7-segment in PORTA
; ISR1 will display '0' on the 7-segment in PORTA 
; Write a program in the “foreground routine” that will read the data IN
; PORTC (lower nibble) AND display the equivalent 7-SEGMENT display IN
; PORTB. For example, if the data read from PORTC is “00000110” then the
; display is ‘6’ (mask the upper nibble). Check if the value is greater
; than 09H. If true, then then display ‘0’ instead. 

DATA    SEGMENT
    ORG 03000H
    P6_COM_REG  EQU 0F6H    ; 8255 Command Register
    P6_PROGRAM  EQU 089H    ; 10001 001 (89H)
                            ; 1---- --- Command Group A
                            ; -00-- --- Mode 0 for PORTA
                            ; ---0- --- Output for PORTA
                            ; ----1 --- Input for PORTC7-4
                            ; ----- 0-- Mode 0 for PORTB
                            ; ----- -0- Output for PORTB
                            ; ----- --1 Input for PORTC3-0
    ONE_DISPLAY EQU 0F0H    ; PORTA 7-segment display (BCD format)
    TWO_DISPLAY EQU 0F2H    ; PORTB 7-segment display (BCD format)
    DIPSW_INPUT EQU 0F4H    ; Dipswitch inputs (Lower nibble only)
    DEFAULT_SEG EQU 00FH    ; Default 7-segment display character

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
                             
DATA    ENDS

STACK   SEGMENT PARA STACK
    DW 64 DUP(?)            ; Reserve 64 words for stack
TOS DW ?                    ; Top of stack marker
STACK   ENDS

; Will display '9' on the PORTA 7-segment
HANDLER0    SEGMENT
ISR0    PROC FAR
    ASSUME CS:HANDLER0, DS:DATA, SS:STACK
    ORG 01000H    
    PUSHF                   ; Housekeeping
    PUSH AX
    PUSH DX
    
    MOV DX, ONE_DISPLAY     ; Display '9' on the first segment
    MOV AL, 9
    OUT DX, AL 
                                   
    POP DX                  ; Housekeeping
    POP AX
    POPF
    IRET 
ISR0    ENDP
HANDLER0    ENDS

; Will display '0' on the PORTA 7-segment
HANDLER1    SEGMENT
ISR1    PROC FAR
    ASSUME CS:HANDLER1, DS:DATA, SS:STACK
    ORG 02000H    
    PUSHF                   ; Housekeeping
    PUSH AX
    PUSH DX                               
    
    MOV DX, ONE_DISPLAY     ; Display '0' on the first segment
    MOV AL, 0
    OUT DX, AL    
    
    POP DX                  ; Housekeeping
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
    ; Load proper register values
    MOV AX, DATA            ; Data Segment      
    MOV DS, AX      
    MOV AX, STACK           ; Stack Segment     
    MOV SS, AX      
    LEA SP, TOS             ; Stack Pointer     
    CLI                     ; Clear IF                     

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
    
    STI      

; Foreground routine
foreground:   
    MOV DX, DIPSW_INPUT     ; Data from dipswitches
    IN AL, DX
    
    CMP AL, 09H             ; Determin if number entered is greater
    JA over_nine            ; than 9
         
    MOV DX, TWO_DISPLAY     ; If not, then display to PORTB as usual
    OUT DX, AL
    JMP foreground
    
    over_nine:              ; If so, display a '0' instead
    MOV DX, TWO_DISPLAY
    MOV AL, 0
    OUT DX, AL
    JMP foreground

HLT             
CODE    ENDS
        END START