; [code finished 5 minutes after deadline (extended)]
; [see TMC2.asm for the unmodified code]

; TMC-2
; Arithmetic instructions. Create an assembly language program that lets
; the user input a value and determines whether that value is odd or even.

CR EQU 0DH      ; Carriage Return
LF EQU 0AH      ; Line Feed

ORG 100H

JMP START
TEXT1 DB 'Input a string: $'
TEXT2 DB CR, LF, 'The string contains $'
TEXT3 DB ' vowel(s)!$'
BUFFR DB 25, ?, 25 DUP(' ')

START:
; Print out TEXT1
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H

; Single character input
    MOV DI, OFFSET BUFFR
    CALL CHAR_INPUT             
    
    MOV DX, 0H
    MOV AX, 0H              ; count number of vowels
    MOV BH, 0H              ; decrementer
    MOV BL, BUFFR[1]
    
    vowel_loop:
        MOV CL, [BUFFR + BX + 1]
        
        CMP CL, 'a'
        JZ inc_a
        CMP CL, 'A'
        JZ inc_a
        CMP CL, 'e'
        JZ inc_a
        CMP CL, 'E'
        JZ inc_a
        CMP CL, 'i'
        JZ inc_a
        CMP CL, 'I'
        JZ inc_a
        CMP CL, 'o'
        JZ inc_a
        CMP CL, 'O'
        JZ inc_a
        CMP CL, 'u'
        JZ inc_a
        CMP CL, 'U'
        JZ inc_a
        
        JMP cont
        
        inc_a:
            INC AX    
        
        cont:
            DEC BX
            CMP BX, DX
            JZ print
            JMP vowel_loop

print:
    PUSH AX    

    ; Print out TEXT2
    MOV AH, 09H
    MOV DX, OFFSET TEXT2
    INT 21H
    
    POP DX
    MOV DH, 0H
    ADD DL, '0'
    
    MOV AH, 02H
    INT 21H 
    
    ; Print out TEXT3
    MOV AH, 09H
    MOV DX, OFFSET TEXT3
    INT 21H

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
        MOV [DI + BX + 2], '$'  ; Insert '$' at end of string
        RET

CHAR_INPUT ENDP