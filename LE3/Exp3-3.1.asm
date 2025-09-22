; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/22
; LE3-3 | Subroutines and DOS Interrupts  

; Activity #1

ORG 100H

.data
BUFFER DB 10,?, 10 DUP(' ') 
 
.code
MOV DX, OFFSET BUFFER 
MOV AH, 0AH 
INT 21H 
   
CALL PRINT 
   
MOV AH,04CH  
INT 021H  
INT 020H 
 
PRINT:  
    XOR BX, BX 
    MOV BL, BUFFER[1] 
    MOV BUFFER[BX + 2], '$' 
    MOV DX, OFFSET BUFFER + 2 
    MOV AH, 9 
    INT 21H 
    RET