; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/22
; LE3-3 | Subroutines and DOS Interrupts  

; Activity #2

ORG 100H

.data
ANAME DB 'Enter name: ', '$'
SNAME DB 25, ?, 25 DUP(' ')

APROGRAM DB 0DH, 0AH, 'Enter program: ', '$'
SPROGRAM DB 25, ?, 25 DUP(' ')

AYEAR DB 0DH, 0AH, 'Enter year level: ', '$'
SYEAR DB 10, ?, 10 DUP(' ')

AREPEAT DB 0DH, 0AH, 'Repeat number of times (single digit): ', '$'

.code
; Name of user
    MOV DX, OFFSET ANAME
    MOV AH, 09H
    INT 21H                     ; Print out ANAME
        
    MOV DI, OFFSET SNAME        ; Character by character input
    CALL CHAR_INPUT             ; Assumed that input characters is less than buffer

; Program of user
    MOV DX, OFFSET APROGRAM
    MOV AH, 09H
    INT 21H
    
    MOV DI, OFFSET SPROGRAM
    CALL CHAR_INPUT

; Year level of user
    MOV DX, OFFSET AYEAR
    MOV AH, 09H
    INT 21H
    
    MOV DI, OFFSET SYEAR
    CALL CHAR_INPUT

; Ask user how many times to print
    MOV DX, OFFSET AREPEAT
    MOV AH, 09H
    INT 21H    
    
    ; Single character input
    MOV AX, 0100H    
    INT 21H
    
    SUB AL, '0'                 ; Convert from ascii value to numeric value
    MOV CL, AL                  ; Use CX as decrementer
    MOV CH, 0                   ; Clear CH
    
    ; Print new line
    MOV AH, 2
    MOV DL, 0DH                 ; Carriage return 
    INT 21H
    MOV DL, 0AH                 ; Line feed                               
    INT 21H
    
    print_rep:
        ; Print user name
        MOV DX, OFFSET SNAME + 2
        MOV AH, 09H
        INT 21H
        
        ; Print user program
        MOV DX, OFFSET SPROGRAM + 2
        MOV AH, 09H
        INT 21H
        
        ; Print user year level
        MOV DX, OFFSET SYEAR + 2
        MOV AH, 09H
        INT 21H        
    LOOP print_rep                  

; exit from program
MOV AH, 4CH
INT 21H

; Procedure for accepting user input 1 character at a time
; Input Registers: DI - Address of buffer
; Will internally use AX, BX 
CHAR_INPUT PROC NEAR
    MOV BX, 0                   ; BL determines the length of string
        
    start_char:
        MOV AX, 0100H    
        INT 21H                 ; Single character input
        
        CMP AL, 0DH             ; Carriage return             
        JZ end_char             ; If user presses enter, then exit loop
    
    next_char:
        INC BL                  ; Increment length of string
        MOV [DI + 1], BL        ; Current length of string in ARR[1]
        
        MOV [DI + BX + 1], AL   ; Current character at end of ARR
        JMP start_char        
        
    end_char:
        INC BL                  
        MOV [DI + 1], BL
        MOV [DI + BX + 1], 0AH  ; Insert line feed
        
        INC BL                  ; Insert carriage return
        MOV [DI + 1], BL
        MOV [DI + BX + 1], 0DH
        
        MOV [DI + BX + 2], '$'  ; Insert '$' at end of string
        RET

CHAR_INPUT ENDP             
