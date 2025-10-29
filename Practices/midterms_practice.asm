; MIDTERMS PRACTICE

; High level implementation
;   Wait until any of the buttons is pressed
;   If so, then grab dip-switch data
;   Jump to relevant arithmetic code section
;   Display digits
;   Repeat forever

PORTA EQU 080H      ; 2 7-segment diplays in BCD format
PORTB EQU 082H      ; 2 4-set dip switches
                    ; MSBs => operand 1
                    ; LSBs => operand 2
PORTC EQU 084H      ; 4 push buttons
                    ; 0000_0001B => Addition
                    ; 0000_0010B => Subtraction
                    ; 0000_0100B => Multiplication
                    ; 0000_1000B => Division
COM_REG EQU 086H    ; Command Register (1000_1011B [08BH])

UF_IND EQU 0AAH     ; 7-segment display if result is negative
OF_IND EQU 0BBH     ; 7-segment display if result is over 99

.code
; Set-up
    ; Program the 8255
    MOV DX, COM_REG
    MOV AL, 08BH
    OUT DX, AL
    
    ; Zero out the displays
    MOV DX, PORTA
    MOV AL, 0
    OUT DX, AL

; Wait until any of the buttons is pressed
main_loop:
    ; Poll PORTC
    MOV DX, PORTC
    IN AL, DX
    
    TEST AL, 0FH    ; If none of the buttons are pressed
    JZ main_loop    ; Then back to main_loop
    
    MOV CH, AL      ; For safe keeping (no variables)
    
; If so, then grab dip-switch data
    MOV DX, PORTB
    IN AL, DX
    
    ; Separating the operands to different registers
    MOV BX, AX      ; AL and BL contains the same number    
    AND BL, 00FH    ; BL => operand 2    
    AND AL, 0F0H    ; AL => operand 1
    MOV CL, 4
    SHR AL, CL    

; Jump to relevant arithmetic code section
    CMP CH, 00000001B
    JE add_arith
    
    CMP CH, 00000010B
    JE sub_arith
    
    CMP CH, 00000100B
    JE mul_arith
    
    CMP CH, 00001000B
    JE div_arith    

    JMP main_loop   ; Fallback (should not execute in normal circumstances)

; Arithmetic results in AX (more specifically in AL)
add_arith:
    ADD AX, BX      ; Maximum would be 15 + 15 = 30 (01FH)
    JMP disp_digits ; So CF will always be 0   
    
sub_arith:
    SUB AX, BX      ; If negative, then borrow (CF = 1)  
    JMP disp_digits
    
mul_arith:
    MUL BL          ; Maximum would be 15 * 15 = 225 (0DEH)
    JMP disp_digits ; So CF will always be 0     

div_arith:
    MOV AH, 0       
    DIV BL          ; AL => whole number part
    MOV AH, 0       ; AH => clear remainder
    JMP disp_digits           
            
; Display digits  
disp_digits:
    MOV DX, PORTA
       
    ; If negative (CF == 1), then output the underflow indicator
    JNC not_negative
    MOV AL, UF_IND
    OUT DX, AL
    JMP main_loop
    not_negative:
    
    ; If over 99, then output the overflow indicator
    CMP AL, 99
    JNG not_overflow
    MOV AL, OF_IND
    OUT DX, AL
    JMP main_loop
    not_overflow:
    
    ; Otherwise display the number normally
    ; Maximum is 99 (063H), should be in BCD format (099H)
    MOV AH, 0       ; Set-up to separate the tens digit to the ones digit
    MOV BX, 10      ; AH => ones digit (0OH)
    DIV BL          ; AL => tens digit (0TH)
    
    MOV CL, 4
    SHL AL, CL      ; AL = (T0H)
    OR AL, AH       ; AL = (TOH)
    
    OUT DX, AL
    JMP main_loop    
; Repeat forever
