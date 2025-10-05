
; MP2
; Assumes input is positive integer less than 255 
        
CR EQU 0DH          ; Carriage Return
LF EQU 0AH          ; Line Feed        
        
ORG 100H

.data
CTEMP DB 10, ?, 10 DUP(' ')
TEXT1 DB "Enter temperature in Celsius: $"
TEXT2 DB CR, LF, "Binary: $"
TEXT3 DB CR, LF, "Hexadecimal: $"

FWHOLE DW ?
FFRACT DW ?

.code
; Set video mode
    MOV AH, 0H
    MOV AL, 03H                 ; text mode. 80x25. 16 colors. 8 pages. 
    INT 10H

; Print TEXT1
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H

; Receive temperature in Celsius
    MOV AH, 0AH
    MOV DX, OFFSET CTEMP
    INT 21H

; Consolidate number from multiple bytes to 1 register
    MOV AX, 0H                  ; Final result in AX
    MOV DI, 0H                  ; Incrementer
    
    cons_loop:
        ; Grab first number
        MOV CL, CTEMP[DI + 2]
        
        ; If enter key then break from loop
        MOV CH, CR
        CMP CL, CH
        JZ c_to_f
        
        ; Otherwise shift current result to the right (x10)
        MOV DX, 10
        MUL DX                  ; Assume (Assert) that hi-word is 0
        
        ; Slot the current number in (+CH)
        MOV CH, 0H
        SUB CX, '0'             ; Ascii code to decimal
        ADD AX, CX
        
        ; Repeat until no numbers to process
        INC DI
        JMP cons_loop     

; Perform conversion calculation
    ; Current temperature in AX    
c_to_f:                         ; (C * 9/5) + 32
    MOV CX, 9
    MUL CX                      ; Assume (Assert) that hi-word is 0
    
    MOV DX, 0
    MOV CX, 5
    DIV CX
    
    ADD AX, 32                  ; AX = Whole part
                                ; DX = Remainder after /5
    
    MOV FWHOLE, AX
    MOV FFRACT, DX

; Print in binary        
    ; Deal with whole number part
    
        MOV CX, 0H              ; Incrementer           
        bin_whole:
            MOV BX, 0
            CMP AX, BX
            JZ prnt_bin_whole
            
            MOV DX, 0
            MOV BX, 2       
            DIV BX              ; Divide by 2
            
            PUSH DX             ; Push remainder to be printed LIFO
            INC CX              ; Count number of times to pop out later
            
            JMP bin_whole                                   
        
        prnt_bin_whole:
        ; Change attributes of text        
            PUSHA               ; Save registers
            MOV AH, 06H
            MOV AL, 00H         ; Entire "screen"
            MOV BH, 09H         ; Black background (0), Blue foreground (9)
            MOV CX, 0107H       ; Exclude row 0, and 7 columns right (Binary text)
            MOV DX, 014FH       ; Rightmost cell
            INT 10H
            POPA                ; Reload registers
        
        ; Print Binary text:
            MOV AH, 09H
            MOV DX, OFFSET TEXT2
            INT 21H
            
        ; Print from stack character by character
            MOV AH, 02H
            disp_bin_whole:
                POP DX
                ADD DX, '0'
                INT 21H
                loop disp_bin_whole
                     
    
    ; Deal with remainder
            MOV AX, FFRACT
            MOV DX, 0
            CMP AX, DX          ; If no remainder then skip calculation
            JZ hex_start
        
        ; Append radix point
            MOV AH, 02H
            MOV DL, '.'
            INT 21H
        
        ; Treat remainder as if whole number    
            MOV CX, 0H            ; Incrementer           
            bin_frac:
                MOV BX, 0
                CMP AX, BX
                JZ prnt_bin_frac
                
                MOV DX, 0
                MOV BX, 2       
                DIV BX              ; Divide by 2
                
                PUSH DX             ; Push remainder to be printed LIFO
                INC CX              ; Count number of times to pop out later
                
                JMP bin_frac                                   
            
            prnt_bin_frac:        
            ; Print from stack character by character
                MOV AH, 02H
                disp_bin_frac:
                    POP DX
                    ADD DX, '0'
                    INT 21H
                    loop disp_bin_frac
    

hex_start:    
; Print in hexadecimal
; Deal with whole number part
    
    MOV AX, FWHOLE
    MOV CX, 0H              ; Incrementer           
    hex_whole:
        MOV BX, 0
        CMP AX, BX
        JZ prnt_hex_whole
        
        MOV DX, 0
        MOV BX, 16       
        DIV BX              ; Divide by 16
        
        PUSH DX             ; Push remainder to be printed LIFO
        INC CX              ; Count number of times to pop out later
        
        JMP hex_whole                                   
    
    prnt_hex_whole:
    ; Change attributes of text
        PUSHA               ; Save registers
        MOV AH, 06H
        MOV AL, 00H         ; Entire "screen"
        MOV BH, 0AH         ; Black background (0), Green foreground (A)
        MOV CX, 020CH       ; Exclude rows 0 ans 1, 13 columns right (Hexadecimal text)
        MOV DX, 184FH       ; Bottom-right cell
        INT 10H
        POPA                ; Reload registers
    
    ; Print Hexadecimal text:
        MOV AH, 09H
        MOV DX, OFFSET TEXT3
        INT 21H
        
    ; Print from stack character by character
        MOV AH, 02H
        disp_hex_whole:
            POP DX
            
            MOV BX, 9
            CMP DX, BX
            JGE prnt_sym    ; Determine if DX is numeric or alphabet
            
            prnt_num:       ; For DX < 10 (A)
            ADD DX, '0'
            JMP nxt_int
            
            prnt_sym:       ; For DX >= 10 (A)
            ADD DX, 'A'
            SUB DX, 10            
                        
            nxt_int:
            INT 21H
            loop disp_hex_whole

    ; Deal with remainder
            MOV AX, FFRACT
            MOV DX, 0
            CMP AX, DX          ; If no remainder then skip calculation
            JZ end_pgrm
    
        ; Append decimal point
            MOV AH, 02H
            MOV DL, '.'
            INT 21H
        
        ; Treat remainder as if whole number    
            MOV CX, 0H              ; Incrementer           
            hex_frac:
                MOV BX, 0
                CMP AX, BX
                JZ prnt_hex_frac
                
                MOV DX, 0
                MOV BX, 16       
                DIV BX              ; Divide by 16
                
                PUSH DX             ; Push remainder to be printed LIFO
                INC CX              ; Count number of times to pop out later
                
                JMP hex_frac                                   
            
            prnt_hex_frac:
            ; Print from stack character by character
                MOV AH, 02H
                disp_hex_frac:
                    POP DX
                    
                    MOV BX, 9
                    CMP DX, BX
                    JGE prnt_sym_f  ; Determine if DX is numeric or alphabet
                    
                    prnt_num_f:     ; For DX < 10 (A)
                    ADD DX, '0'
                    JMP nxt_int_f
                    
                    prnt_sym_f:     ; For DX >= 10 (A)
                    ADD DX, 'A'
                    SUB DX, 10            
                                
                    nxt_int_f:
                    INT 21H
                    loop disp_hex_frac                
            
                   

end_pgrm:
    HLT
