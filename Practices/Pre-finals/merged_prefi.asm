
DATA        SEGMENT
    ORG 01000H

    PORT4_PRG_REG   EQU 066H        ; 8255 Program Register
    PORT4_PROGRAM   EQU 089H        ; 10001 001 (89H)
    LCD_BUS         EQU 060H        ; LCD Data lines
    LCD_CNTRL       EQU 062H        ; LCD Contror signals
                                    ; ---E ---R
    KPD_DATA        EQU 064H        ; Keypad Data lines (lower nibble only)
    
    PORT5_PRG_REG   EQU 06EH        ; 8255 Program Register
    PORT5_PROGRAM   EQU 080H        ; 10000 000 (80H)
    SEC_BLINK       EQU 068H        ; LED accurate blinker
    SFT_BLINK       EQU 06AH        ; LED software-delay blinker
    CONST_DELAY     EQU 00A00H      ; Software delay constant
    
    PORT6_PRG_REG   EQU 076H        ; 8253 Program Register
    PORT6_PROGRAM   EQU 038H        ; 00 11 100 0 (38H)
    TIMER_DATA      EQU 070H        ; Timer 0 Port
    TIMER_LSB       EQU 0D0H        ; (2kHz = 07D0H)
    TIMER_MSB       EQU 007H 
    
    PIC0            EQU 078H        ; 01 111 00 0 (78H)
    PIC1            EQU 07AH        ; 01 111 01 0 (7AH)
    
    ICW1            EQU 013H        ; 000 1 0 0 11 (13H)
    ICW2            EQU 080H        ; 80H - 87H
    ICW4            EQU 003H        ; 000 0 00 1 1 (03H)
    OCW1            EQU 0FCH        ; 1111 1100 (FCH)
    
    ; Variables
    SEC_STATE   DB 1
    SFT_STATE   DB 0                                
    
    
DATA        ENDS


STACK       SEGMENT PARA STACK
    DW 64 DUP(?)
TOS DW ?
STACK ENDS


HANDLER0    SEGMENT
        ORG 01000H
ISR0        PROC FAR
        ASSUME CS:HANDLER0, DS:DATA, SS:STACK

    PUSHF
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV DX, SEC_BLINK
    NOT SEC_STATE
    MOV AL, SEC_STATE
    OUT DX, AL        
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POPF                
IRET        
ISR0        ENDP
HANDLER0    ENDS

HANDLER1    SEGMENT
        ORG 02000H
ISR1    PROC FAR
        ASSUME CS:HANDLER1, DS:DATA, SS:STACK
    PUSHF
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV DX, SEC_BLINK
    NOT SEC_STATE
    MOV AL, SEC_STATE
    OUT DX, AL    
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POPF                
IRET          
ISR1    ENDP
HANDLER1    ENDS        

CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STACK
        ORG 04000H
        
START:
; Set-up
    CLI
    
    MOV AX, DATA            ; Data Segment      
    MOV DS, AX      
    MOV AX, STACK           ; Stack Segment     
    MOV SS, AX      
    LEA SP, TOS             ; Stack Pointer    
        
    ; 8255
    MOV DX, PORT4_PRG_REG
    MOV AL, PORT4_PROGRAM
    OUT DX, AL
    
    MOV DX, PORT5_PRG_REG
    MOV AL, PORT5_PROGRAM
    OUT DX, AL
    
    ; LCD Initialization
    MOV AL, 038H            ; Function set
    CALL LCD_INST
    
    MOV AL, 00CH            ; Display ON
    CALL LCD_INST
    
    MOV AL, 001H            ; Clear Display
    CALL LCD_INST
    
    MOV AL, 006H            ; Entry Mode Set           
    CALL LCD_INST
    
    ; 8259
    MOV DX, PIC0
    MOV AL, ICW1
    OUT DX, AL
    
    MOV DX, PIC1
    MOV AL, ICW2
    OUT DX, AL
    
    MOV AL, ICW4
    OUT DX, AL
    
    MOV AL, OCW1
    OUT DX, AL
    
    ; IV Table
    XOR AX, AX
    MOV ES, AX
    
    MOV AX, OFFSET ISR0
    MOV [ES:0200H], AX
    MOV AX, SEG ISR0
    MOV [ES:0202H], AX
    
    MOV AX, OFFSET ISR1
    MOV [ES:0204H], AX
    MOV AX, SEG ISR1
    MOV [ES:0206H], AX    
    
    ; Timer
    MOV DX, PORT6_PRG_REG
    MOV AL, PORT6_PROGRAM
    OUT DX, AL
    
    MOV DX, TIMER_DATA
    MOV AL, TIMER_LSB
    OUT DX, AL
    
    MOV AL, TIMER_MSB
    OUT DX, AL
    
    ; LEDS   
    MOV DX, SEC_BLINK
    MOV AL, SEC_STATE
    OUT DX, AL    
    
    MOV DX, SFT_BLINK
    MOV AL, SFT_STATE
    OUT DX, AL 

    STI       


foreground:

    MOV CX, 010H
    blinking:
    CALL delay
    LOOP blinking
    
    NOT SFT_STATE
    MOV AL, SFT_STATE
    OUT DX, AL   

    JMP foreground

HLT

; LCD Instruction byte
LCD_INST:
    PUSH AX
    PUSH DX
    
    MOV DX, LCD_BUS
    OUT DX, AL
    
    MOV DX, LCD_CNTRL
    MOV AL, 010H
    OUT DX, AL
    CALL DELAY
    
    MOV AL, 000H
    OUT DX, AL     

    POP DX
    POP AX
    
RET    


; LCD Data byte
LCD_DATA:
    PUSH AX
    PUSH DX
    
    MOV DX, LCD_BUS
    OUT DX, AL
    
    MOV DX, LCD_CNTRL
    MOV AL, 011H
    OUT DX, AL
    CALL DELAY
    
    MOV AL, 001H
    OUT DX, AL     

    POP DX
    POP AX
RET    

; Software defined delay
DELAY:
    PUSH CX  
    MOV CX, CONST_DELAY
    _lp:
    NOP
    LOOP _lp 
    POP CX
RET

CODE    ENDS
        END START