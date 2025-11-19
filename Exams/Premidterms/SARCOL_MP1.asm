
; MP1 
        
CR EQU 0DH          ; Carriage Return
LF EQU 0AH          ; Line Feed        
        
ORG 100H

.data
PASS1 DB 25, ?, 25 DUP(' ')
PASS2 DB 25, ?, 25 DUP(' ')
TEXT1 DB "Set-up password: $"
TEXT2 DB CR, LF, "Enter password: $"
TEXT3 DB CR, LF, "Access Granted!$"
TEXT4 DB CR, LF, "Access Denied!$"

.code
; Print TEXT1
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H

; Receive password1
    MOV AH, 0AH
    MOV DX, OFFSET PASS1
    INT 21H


; Print TEXT2
    MOV AH, 09H
    MOV DX, OFFSET TEXT2
    INT 21H
 
; Receive password2 character by character
    
    MOV BX, 0H      ; Incrementer
    char_loop:
        ; Clear buffer, no echo
        MOV AX, 0C07H
        INT 21H
        
        ; If enter key, then break
        MOV DL, CR
        CMP AL, DL
        JZ comp_pass
        
        ; Insert character at next available memory
        MOV PASS2[BX + 2], AL
        INC BX
        
        ; Insert mask characters
        MOV AH, 02H
        MOV DL, '*'
        INT 21H
        
        ; Repeat loop until enter key pressed
        JMP char_loop
    
    
comp_pass:
; Add size of input text to PASS2
    MOV PASS2[1], BL    

; Compare passwords
    ; Assume ES = DS
    MOV DI, OFFSET PASS1 + 1        ; Start from size of PASS1
    MOV SI, OFFSET PASS2 + 1        ; Start from size of PASS2
    MOV CH, 0H
    MOV CL, PASS1[1]                ; Loop by the number of characters in PASS1                
    INC CL                          ; plus the size itself
    
    ; Compare byte by byte
    CLD                             ; Forward direction
    REPE CMPSB                      ; Compare character by character CX times
    JNZ not_equal                   ; If at any point a character is mismatched-
    
; Decide and print result
equal:
    MOV AH, 09H
    MOV DX, OFFSET TEXT3
    INT 21H
    HLT


not_equal:
    MOV AH, 09H
    MOV DX, OFFSET TEXT4
    INT 21H
    HLT

 
 
 

