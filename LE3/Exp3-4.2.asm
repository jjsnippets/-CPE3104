; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/23
; LE3-4 | BIOS Interrupts  

; Activity #2

BG EQU 06H                      ; Black background (0) Brown foreground (6)

ORG 100H

.data
TEXT1 DB    'Enter text to be displayed: $'
BUFF1 DB    70, ?, 70 DUP(' ')
 
.code
; Prompt and enter text
    MOV AH, 09H
    MOV DX, OFFSET TEXT1
    INT 21H                     ; Print out TEXT1
        
    MOV AH, 0AH
    MOV DX, OFFSET BUFF1          
    INT 21H                     ; Accept user input
    
    MOV BX, 0
    MOV BL, BUFF1[1]
    MOV [BX + BUFF1 + 2], '$'   ; Insert $ at end of input
    
; Clear screen
    MOV AH, 06H                 ; Scroll up window
    MOV AL, 00H                 ; Screen scroll (clear)  
    MOV BH, BG                  ; Bright blue background (9),
                                ; Yellow foreground (E)
    MOV CX, 0000H               ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH               ; Bottom-right corner: DH = 24, DL = 79
    INT 10H   
    
; Calculate center offset
    MOV AH, 0H
    MOV AL, BUFF1[1]
    MOV BH, 2
    DIV BH                      ; Divide text length by 2
    MOV AH, 0                   ; Round-down
    MOV DX, 0027H               ; Center position
    SUB DX, AX                  ; Minus some text offset to center to screen
    
; Move cursor to top-center
    MOV AH, 02H                 ; Set cursor position
    MOV BH, 00H                 ; Page 0    
                                ; MOV DX: To center of screen
    INT 10H       

; Print user text    
    MOV AH, 09H
    MOV DX, OFFSET [BUFF1 + 2]
    INT 21H                     
    
    MOV CX, 18H                 ; Loop to be ran 24 times
screen_scroll:
    PUSH CX                     ; Save loop value
    
    MOV AH, 07H                 ; Scroll down window
    MOV AL, 01H                 ; Single line scroll  
    MOV BH, BG                  ; Background color
    MOV CX, 0000H               ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH               ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    POP CX                      ; Load loop value
    LOOP screen_scroll
    
; exit from program
    MOV AH, 4CH
    INT 21H     