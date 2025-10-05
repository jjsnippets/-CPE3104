; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/27
; LE3-6 | BIOS Interrupts  

; Activity #2a 

; Determine if there is a number in a string

CR EQU 0DH                      ; Carriage Return
LF EQU 0AH                      ; Line Feed

ORG 100H

.data
TEXT1 DB    'Enter string to be checked: $'
TEXT2 DB    CR, LF, 'Text has number(s) in it!$'
TEXT3 DB    CR, LF, 'Text has no numbers in it.$'
BUFFR DB    25, ?, 25 DUP(' ')
 
.code
menu:
    ; Print user prompt text
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H
    
    ; Accept user input
    MOV AH, 0AH
    MOV DX, OFFSET BUFFR
    INT 21H
   
    ; Check character if numeric one-by-one 
    MOV BX, 0                   ; Incrementer    
    num_check:    
        CMP BL, BUFFR[1]        ; Check how many characters to check
        JE no_num
        
        MOV AL, BUFFR[BX + 2]   ; Compare character       
        SUB AL, '0'             ; Shift range so that ascii 0 is value 0
        CMP AL, 9               ; Unsigned compare ( <= 9)
        JBE is_num              ; If within 0-9, then there is a number  
        
        INC BX
        JMP num_check           ; Repeat loop
    
    ; If there is no number in text:
    no_num:
        MOV AH, 09H
        MOV DX, OFFSET TEXT3
        INT 21H
        JMP term     
    
    ; Otherwise, there is number in text:    
    is_num:
        MOV AH, 09H
        MOV DX, OFFSET TEXT2
        INT 21H        

; Exit from program    
term:
    MOV AH, 4CH
    INT 21H
     