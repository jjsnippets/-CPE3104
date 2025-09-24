; [submitted code from ceac1; code presented as is]

; TMC-3
; Logic/String instructions. Create an assembly language program that lets the user input a string.
; The program shall rotate in-place the characters from left to right

CR EQU 0DH      ; Carriage Return
LF EQU 0AH      ; Line Feed

ORG 100H

JMP START
TEXT DB 'Input a string: $'
ENTR DB CR, LF, '$'
INPT DB 25, ?, 25 DUP(' ')

START:
; Print out TEXT1
    MOV AH, 09H
    MOV DX, OFFSET TEXT
    INT 21H

; Single character input
    MOV DI, OFFSET INPT
    CALL CHAR_INPUT             
    
    MOV CX, 0H
    MOV BH, 0H              ; decrementer
    MOV BL, INPT[1]
    INC BX
    
    print_loop:
        MOV AH, 09H
        MOV DX, OFFSET ENTR
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET INPT+2
        INT 21H
        
        PUSH BX
        MOV BL, INPT[1]
        DEC BX
        
        rotate_loop:
            MOV DH, INPT[BX + 2]
            MOV DL, INPT[BX + 1]
            
            XCHG DH, DL
            
            MOV INPT[BX + 2], DH
            MOV INPT[BX + 1], DL
            
            DEC BX
            CMP BX, CX
            JNZ rotate_loop
            
        POP BX
        DEC BX
        CMP BX, CX
        JNZ print_loop    

term:
    
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
        MOV [DI + BX + 1], '$'  ; Insert '$' at end of string
        RET

CHAR_INPUT ENDP