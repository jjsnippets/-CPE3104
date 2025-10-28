; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/10/28
; U6 - I/0 Interfacing

Part II | Do the following:
; Based on the circuit below, write an assembly program that will display
; '0' to '9' IN port F2H at 1 second interval. The count will reset AND
; continue until the simulation is stopped.    

PORTB EQU 0F2H 

ORG 100H

.data
; Assuming that the 7-segment display is common cathode (1 => ON)
; Segments position: ABCD_EFG_DP
DIGITS DB 1111_110_0B, 0110_000_0B, 1101_101_0B, 1111_001_0B,   ; 0, 1, 2, 3
       DB 0110_011_0B, 1011_011_0B, 1011_111_0B, 1110_000_0B,   ; 4, 5, 6, 7
       DB 1111_111_0B, 1111_011_0B                              ; 8, 9

.code
; Set-up
    MOV DX, PORTB            ; To the port with the 7-segment display
    MOV SI, OFFSET DIGITS   ; Array pointer
    MOV BX, 0               ; Incrementer to the loop
    
; Continuous loop for displaying numbers in the 7-segment display                              
    count_loop: 
        MOV AL, [SI + BX]   ; Index the BXth element of DIGITS
        OUT DX, AL          ; To 7-segment display
        INC BX              ; Next digit
        
        ; BX MOD 10 (without DIV)
        CMP BX, 10
        JNE skip_mod
        SUB BX, 10
        skip_mod:
        
        ; Delay by 1 second
        PUSH BX
        CALL DELAY_1MS
        POP BX   
         
        JMP count_loop      ; Infinite loop                       

; Use the following code to generate a 1 second delay.
; CALL this code to execute the delay (CALL DELAY_1MS).
DELAY_1MS:
   MOV BX, 02CAH
L1:
   DEC BX
   NOP
   JNZ L1
   RET
