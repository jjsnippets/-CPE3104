; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/27
; LE3-6 | BIOS Interrupts  

; Activity #2b

; Determine if a string is a palindrome or not 

CR EQU 0DH                      ; Carriage Return
LF EQU 0AH                      ; Line Feed

ORG 100H

.data
TEXT1 DB    'Enter string to be checked: $'
TEXT2 DB    CR, LF, 'Text is a palindrome!$'
TEXT3 DB    CR, LF, 'Text is not a palindrome.$'
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
   
    ; Check character place-by-place 
    MOV SI, 1                   ; Incrementer
    MOV BH, 0
    MOV BL, BUFFR[1]            ; Decrementer    
    palindrome_check:    
        CMP BX, 0               ; If no more characters to check
        JE is_palindrome        ; Then pass test
        
        MOV AL, BUFFR[SI + 1]   ; Grab character from the left
        AND AL, 1101_1111B      ; Exclude bit 5 (Upper/lowercase)
        MOV AH, BUFFR[BX + 1]   ; Grab character from the right
        AND AH, 1101_1111B      ; Exclude bit 5 (Upper/lowercase)       
        
        CMP AH, AL              ; If any character is mismatched
        JNE not_palindrome      ; Then fail test
        
        INC SI                  ; March positions
        DEC BX                      
        JMP palindrome_check    ; Repeat loop
    
    ; If user input is palindrome:
    is_palindrome:
        MOV AH, 09H
        MOV DX, OFFSET TEXT2
        INT 21H
        JMP term     
    
    ; Otherwise, it is not palindrome:    
    not_palindrome:
        MOV AH, 09H
        MOV DX, OFFSET TEXT3
        INT 21H        

; Exit from program    
term:
    MOV AH, 4CH
    INT 21H
     