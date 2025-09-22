; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/22
; LE3-3 | Subroutines and DOS Interrupts  

; Activity #2

ORG 100H

.data
NAME DB 25, 25 DUP(' ')
PROGRAM DB 25, 25 DUP(' ')
YEAR DB 5, 5 DUP(' ')
COMBINED DB 55, 5 DUP (' ')
REPEAT DB ?

ANAME DB 'Enter name: ', '$'
APROGRAM DB 0DH, 0AH, 'Enter program: ', '$'
AYEAR DB 0DH, 0AH, 'Enter year level: ', '$'
AREPEAT DB 0DH, 0AH, 'Repeat number of times (single digit): ', '$'

.code
; Print out ANAME
MOV DX, OFFSET ANAME
MOV AH, 09H
INT 21H

; Character by character input
MOV BX, OFFSET NAME[0]
; Assumed that input characters is less than buffer
CALL CHAR_INPUT
RET

; 
CHAR_INPUT PROC NEAR
    ; DI is clobbered, might want to push before running procedure
    MOV DI, 0                   ; DI determines the length of string
        
    loop_start:
        MOV AH, 2
        INT 21H                 ; Single character input
        
        CMP AL, '$'             ; If input is $, the exit loop
        JNZ loop_end   
    
    next_char:
        INC DI                  ; Increment length of string
        MOV [BX + 1], DI        ; Current length of string in ARR[1]
        
        MOV [BX + DI + 2], AL   ; Current character at end of ARR
        JMP loop_start        
        
    loop_end:
        MOV [BX + DI + 2], '$'  ; Insert '$' at end of string

CHAR_INPUT ENDP             
               
