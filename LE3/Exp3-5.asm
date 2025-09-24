; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/22
; LE3-4 | BIOS Interrupts  

; Activity #1

CR EQU 0DH              ; Carriage Return
LF EQU 0AH              ; Line Feed

COL1 EQU 00F_00H        ; Black background (0), White foreground (F)
COL2 EQU 0DF_00H        ; Magenta background (D), White foreground (F)
COL3 EQU 0EF_00H        ; Yellow background (E), White foreground (F)
COL4 EQU 09F_00H        ; Blue background (9), White foreground (F)

ORG 100H

.data
TEXT1 DB    'MENU$'
TEXT2 DB    '1 - HORIZONTAL STRIPES', CR, LF, '2 - VERTICAL STRIPES', CR, LF, '3 - CHECKERED PATTERN', CR, LF, CR, LF, 'Q - QUIT', CR, LF, '$'
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
    
    ; Else if input == '3', then checkered pattern
    CMP AL, '3'
    JZ checker_patt    
    
    ; Else, reprompt
    JMP menu

HCOLOR DW COL1, COL2, COL3, COL4
; 7 black lines, 6 lines for the rest  
HCOORD DW 0000H, 0600H, 0C00H, 1200H
hort_stripes:    
    MOV BX, 00H         
    hloop:              ; Loop to run 4 times
        
        MOV SI, W.HCOLOR[BX]
        MOV DI, W.HCOORD[BX]
        CALL RECT_DRAW
        
        INC BX
        INC BX
        CMP BX, 08H
        JNZ hloop   
    
    CALL ANY_KEY 
    
    ; Back to start of code (menu)
    JMP menu    

VCOLOR DW COL1, COL2, COL3, COL4
; 20 lines each  
VCOORD DW 0000H, 0013H, 0027H, 003BH    
vert_stripes:    
    MOV BX, 00H         
    vloop:              ; Loop to run 4 times
        
        MOV SI, W.VCOLOR[BX]
        MOV DI, W.VCOORD[BX]
        CALL RECT_DRAW
        
        INC BX
        INC BX
        CMP BX, 08H
        JNZ vloop
    
    CALL ANY_KEY 
    
    ; Back to start of code (menu)
    JMP menu 

CCOLOR DW COL1, COL2, COL3, COL4, COL2, COL3, COL4, COL1, COL3, COL4, COL1, COL2, COL4, COL1, COL2, COL3 
CCOORD DW 00000H, 00013H, 00027H, 0003BH, 00600H, 00613H, 00627H, 0063BH, 00C00H, 00C13H, 00C27H, 00C3BH, 01200H, 01213H, 01227H, 0123BH
checker_patt:
    MOV BX, 00H         
    cloop:              ; Loop to run 16 times
        
        MOV SI, W.CCOLOR[BX]
        MOV DI, W.CCOORD[BX]
        CALL RECT_DRAW
        
        INC BX
        INC BX
        CMP BX, 20H
        JNZ cloop
    
    CALL ANY_KEY
    
    ; Back to start of code (menu)
    JMP menu

term:
    ; exit from program
    MOV AH, 4CH
    INT 21H

; Procedure for clearing the screen black    
CLEAR_SCREEN PROC
    PUSHA               ; Save register values to be clobbered
    
    MOV AH, 00H         ; Set video mode
    MOV AL, 03H         ; Text mode. 80x25. 16 colors. 8 pages
    INT 10H
    
    POPA                ; Restore saved values   
    RET    
CLEAR_SCREEN ENDP

; Procedure for printing a message at (CH, CL)
; Inputs:   DX - Address of string to be printed
;           CX - Position of string to be printed (CH, CL)
DISP_MESS PROC
    PUSHA               ; Save register values to be clobbered
    PUSH DX             ; Save another copy
    
    ; Set cursor position to (CH, CL)
    MOV AH, 02H         ; Set cursor position
    MOV BH, 00H         ; Page 0
    MOV DX, CX          ; At position (CH, CL)
    INT 10H
    
    ; Print first line of text
    POP DX              ; Retrieve DX from stack
    MOV AH, 09H
    INT 21H
    
    POPA                ; Restore saved values   
    RET
DISP_MESS ENDP

; Procedure for filling out a screen with a rectangle of specified color
; From a specified corner to the bottom right
; Inputs:   SI - screen attributes
;           DI - Top-left corner of rectangle              
RECT_DRAW PROC
    PUSHA               ; Save register values to be clobbered
    
    MOV AH, 06H         ; Scroll up window
    MOV AL, 00H         ; Screen scroll (clear)  
    MOV BX, SI          ; Screen attributes
    MOV CX, DI          ; Top-left corner
    MOV DX, 184FH       ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    POPA                ; Restore saved values   
    RET        
RECT_DRAW ENDP

; Procedure for prompting user to press any key
ANY_KEY PROC
    PUSHA               ; Save register values to be clobbered
    
    ; Hide cursor
    MOV AH, 01H
    MOV CH, 0010_0000B  ; Bit 5 set to 1 (invisible)   
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
    MOV CH, 0000_0110B  ; Bit 5 set to 0 (visible)
    MOV CL, 0000_0111B  ; Small vertical bar 
    INT 10H
    
    POPA                ; Restore saved values
    RET
ANY_KEY ENDP     