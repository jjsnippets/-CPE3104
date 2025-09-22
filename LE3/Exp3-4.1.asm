; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/22
; LE3-4 | BIOS Interrupts  

; Activity #1

CR EQU 0DH      ; Carriage Return
LF EQU 0AH      ; Line Feed

ORG 100H

.data
TEXT1 DB    'MENU$'
TEXT2 DB    '1 - HORIZONTAL STRIPES', CR, LF, '2 - VERTICAL STRIPES', CR, LF, CR, LF, 'Q - QUIT', CR, LF, '$'
TEXT3 DB    'ENTER CHOICE: $'
TEXT4 DB    'Press any key to continue$'
 
.code
menu:
    CALL CLEAR_SCREEN
    
    ; Set screen to blue
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 9EH         ; Bright blue background (9), Yellow foreground (E)
    MOV CX, 0000H       ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; Print first line of text
    MOV DX, OFFSET TEXT1
    MOV CX, 0226H       ; At (2, 38)
    CALL DISP_MESS
    
    ; Print second line of text
    MOV DX, OFFSET TEXT2
    MOV CX, 0400H       ; At (4, 0)
    CALL DISP_MESS   
    
    ; Print last line of text
    MOV DX, OFFSET TEXT3
    MOV CX, 0914H       ; At (9, 20)
    CALL DISP_MESS
    
    ; Single character input
    MOV AX, 0C01H       ; Clear buffer before accepting input    
    INT 21H             ; AL = 01H for echo
    
    ; If input == 'q', then quit program
    CMP AL, 'q'
    JZ term
    CMP AL, 'Q'
    JZ term
    
    ; Else if input == '1', then horizontal stripes
    CMP AL, '1'
    JZ hort_stripes
    
    ; Else if input == '2', then vertical stripes
    CMP AL, '2'
    JZ vert_stripes
    
    ; Else, reprompt
    JMP menu

hort_stripes:
    CALL CLEAR_SCREEN
    
    ; Black-Magenta-Yellow-Blue
    ; 7 black lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 00H         ; Black background (0), Black foreground (0)
    MOV CX, 0000H       ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 6 magenta lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 0D0H        ; Magenta background (D), Black foreground (0)
    MOV CX, 0600H       ; 6 rows down: CH = 6, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 6 yellow lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 0E0H        ; Yellow background (E), Black foreground (0)
    MOV CX, 0C00H       ; 6 more rows down: CH = 12, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 6 blue lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 090H        ; Blue background (9), Black foreground (0)
    MOV CX, 1200H       ; 7 more rows down: CH = 18, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; Hide cursor
    MOV AH, 01H
    MOV CH, 00100000B   ; Bit 5 set to 1 (invisible)   
    INT 10H
    
    ; Print interstitial text
    MOV DX, OFFSET TEXT4
    MOV CX, 0171BH      ; At (23, 27)
    CALL DISP_MESS   
    
    ; Awaiting input
    MOV AX, 0C07H       ; Clear buffer before accepting input    
    INT 21H             ; AL = 07H for no echo
    
    ; Reveal cursor
    MOV AH, 01H
    MOV CH, 00000110B   ; Bit 5 set to 0 (visible)
    MOV CL, 00000111B   ; Small vertical bar 
    INT 10H 
    
    ; Back to start of code (menu)
    JMP menu    
    
vert_stripes:
    CALL CLEAR_SCREEN
    
    ; Black-Magenta-Yellow-Blue
    ; 20 black lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 00H         ; Black background (0), Black foreground (0)
    MOV CX, 0000H       ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 20 magenta lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 0D0H        ; Magenta background (D), Black foreground (0)
    MOV CX, 0013H       ; 20 columns to the right: CH = 0, CL = 19
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 20 yellow lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 0E0H        ; Yellow background (E), Black foreground (0)
    MOV CX, 0027H       ; 20 more columns to the right: CH = 0, CL = 39
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; 20 magenta lines
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BH, 090H        ; Blue background (9), Black foreground (0)
    MOV CX, 003BH       ; 20 more columns to the right: CH = 0, CL = 59
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; Hide cursor
    MOV AH, 01H
    MOV CH, 00100000B   ; Bit 5 set to 1 (invisible)   
    INT 10H
    
    ; Print interstitial text
    MOV DX, OFFSET TEXT4
    MOV CX, 0171BH      ; At (23, 27)
    CALL DISP_MESS   
    
    ; Awaiting input
    MOV AX, 0C07H       ; Clear buffer before accepting input    
    INT 21H             ; AL = 07 for no echo
    
    ; Reveal cursor
    MOV AH, 01H
    MOV CH, 00000110B   ; Bit 5 set to 0 (visible)
    MOV CL, 00000111B   ; Small vertical bar 
    INT 10H 
    
    ; Back to start of code (menu)
    JMP menu 

term:
    ; exit from program
    MOV AH, 4CH
    INT 21H

; Procedure for clearing the screen black    
CLEAR_SCREEN PROC NEAR
    PUSH AX             ; Save register values to be clobbered
    
    MOV AH, 00H         ; Set video mode
    MOV AL, 03H         ; Text mode. 80x25. 16 colors. 8 pages
    INT 10H
    
    POP AX              ; Restore saved values    
    RET    
CLEAR_SCREEN ENDP

; Procedure for printing a message at (CH, CL)
; Inputs:   DX - Address of string to be printed
;           CX - Position of string to be printed (CH, CL)
DISP_MESS PROC NEAR
    PUSH AX             ; Save register values to be clobbered
    PUSH BX
    PUSH DX             ; Save DX
    
    ; Set cursor position to (CH, CL)
    MOV AH, 02H         ; Set cursor position
    MOV BH, 00H         ; Page 0
    MOV DX, CX          ; At position (CH, CL)
    INT 10H
    
    ; Print first line of text
    POP DX              ; Retrieve DX from stack
    MOV AH, 09H
    INT 21H
    
    POP BX              ; Restore saved values
    POP AX  
    RET
DISP_MESS ENDP
