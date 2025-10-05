; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/27
; LE3-5 | Mouse and Keyboard Programming

; Activity #1  

CR EQU 0DH                  ; Carriage Return
LF EQU 0AH                  ; Line Feed
F1 EQU 20H                  ; F1 key (Change to 3BH if necessary)

COL1 EQU 00F_00H            ; Black background (0), White foreground (F)
COL2 EQU 0DF_00H            ; Magenta background (D), White foreground (F)
COL3 EQU 0EF_00H            ; Yellow background (E), White foreground (F)
COL4 EQU 09F_00H            ; Blue background (9), White foreground (F)

XCORD1 EQU 4                ; Coordinates of the screen text "buttons"
YCORD1 EQU 21
XCORD2 EQU 5
YCORD2 EQU 19
XCORD3 EQU 6
YCORD3 EQU 21

ORG 100H

.data
TEXT1 DB    'MENU$'
TEXT2 DB    '1 - HORIZONTAL STRIPES', CR, LF, '2 - VERTICAL STRIPES', CR, LF, 'F1 - CHECKERED PATTERN', CR, LF, CR, LF, 'Q - QUIT', CR, LF, '$'
TEXT3 DB    'ENTER CHOICE: $'
TEXT4 DB    'Press any key to continue$'
 
.code
menu:
    ; disable blinking
    MOV AX, 1003H
    MOV BX, 0
    INT 10H

    CALL CLEAR_SCREEN
    
    ; Set screen to blue
    MOV AH, 06H             ; Scroll up window
    MOV AL, 00H             ; Screen scroll (clear)  
    MOV BH, 9EH             ; Bright blue background (9), Yellow foreground (E)
    MOV CX, 0000H           ; Top-left corner: CH = 0, CL = 0
    MOV DX, 184FH           ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    ; Print first line of text
    MOV DX, OFFSET TEXT1
    MOV CX, 0226H           ; At (2, 38)
    CALL DISP_MESS
    
    ; Print second line of text
    MOV DX, OFFSET TEXT2
    MOV CX, 0400H           ; At (4, 0)
    CALL DISP_MESS   
    
    ; Print last line of text
    MOV DX, OFFSET TEXT3
    MOV CX, 0914H           ; At (9, 20)
    CALL DISP_MESS
    
    ; Show mouse pointer
    MOV AX, 01H
    INT 33H   
    
    ; Reveal cursor    
    MOV AH, 01H
    MOV CH, 0000_0110B      ; Bit 5 set to 0 (visible)
    MOV CL, 0000_0111B      ; Small vertical bar 
    INT 10H                 ; Issue: INT 21H/00H does display blinking cursor
    
    ; repeatedly poll for input
    rep_recieve:
        ; Check keystroke from buffer
        MOV AH, 01H         ; ZF = 0 if keystroke available     
        INT 16H             ; AH = scancode, AL = ascii code
        JNZ have_key
        
        ; Check mouse clicks
        MOV AX, 03H         ; BX = 1 when left click, BX = 2 when right click
        INT 33H             ; CX = x-pos, DX = y-pos
        CMP BX, 0
        JNZ have_mouse       
                
        ; If no input, then repeat loop
        JMP rep_recieve                     
        
    have_key:
        ; Consume key press
        MOV AH, 00H
        INT 16H             
        
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
        
        ; Else if input == 'F1', then checkered pattern
        CMP AH, F1
        JZ checker_patt    
        
        ; Else, reprompt (safe)
        JMP rep_recieve
    
    have_mouse:
        ; Y-coordinate checking
        MOV AX, DX
        MOV DX, 0
        MOV BX, 8 
        
        DIV BX              ; Y-value divide by 8
        MOV DX, 0           ; Clear remainder
        
        CMP AX, XCORD1      ; Switch-case to particular line
        JE yloc_1
        CMP AX, XCORD2
        JE yloc_2
        CMP AX, XCORD3
        JE yloc_3
        JMP rep_recieve     ; Otherwise, go back to recieving inputs
        
        ; X-coordinate checking refinement
        ; So that only cells with text are valid "buttons"        
        yloc_1:
        MOV AX, CX
        DIV BX
        
        CMP AX, YCORD1
        JLE hort_stripes
        JMP rep_recieve        
        
        yloc_2:
        MOV AX, CX
        DIV BX
        
        CMP AX, YCORD2
        JLE vert_stripes
        JMP rep_recieve
        
        yloc_3:            
        MOV AX, CX
        DIV BX
        
        CMP AX, YCORD3
        JLE checker_patt
        JMP rep_recieve        
   

HCOLOR DW COL1, COL2, COL3, COL4
; 7 black lines, 6 lines for the rest  
HCOORD DW 0000H, 0600H, 0C00H, 1200H
hort_stripes:
    CALL CLEAR_SCREEN
    
    MOV BX, 00H         
    hloop:                  ; Loop to run 4 times
        
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
    CALL CLEAR_SCREEN
    
    MOV BX, 00H         
    vloop:                  ; Loop to run 4 times
        
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
    CALL CLEAR_SCREEN

    MOV BX, 00H         
    cloop:                  ; Loop to run 16 times
        
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
; Also resets/checks for mouse cursor    
CLEAR_SCREEN PROC
    PUSHA                   ; Save register values to be clobbered
    
    MOV AX, 02H             ; Hide cursor
    INT 33H
    
    MOV AX, 0H              ; Check for mouse status
    INT 33H    
    CMP AX, 0H              ; If no mouse, then halt          
    JE term
    
    MOV AH, 00H             ; Set video mode
    MOV AL, 03H             ; Text mode. 80x25. 16 colors. 8 pages
    INT 10H
    
    POPA                    ; Restore saved values   
    RET    
CLEAR_SCREEN ENDP

; Procedure for printing a message at (CH, CL)
; Inputs:   DX - Address of string to be printed
;           CX - Position of string to be printed (CH, CL)
DISP_MESS PROC
    PUSHA                   ; Save register values to be clobbered
    PUSH DX                 ; Save another copy
    
    ; Set cursor position to (CH, CL)
    MOV AH, 02H             ; Set cursor position
    MOV BH, 00H             ; Page 0
    MOV DX, CX              ; At position (CH, CL)
    INT 10H
    
    ; Print first line of text
    POP DX                  ; Retrieve DX from stack
    MOV AH, 09H
    INT 21H
    
    POPA                    ; Restore saved values   
    RET
DISP_MESS ENDP

; Procedure for filling out a screen with a rectangle of specified color
; From a specified corner to the bottom right
; Inputs:   SI - screen attributes
;           DI - Top-left corner of rectangle              
RECT_DRAW PROC
    PUSHA                   ; Save register values to be clobbered
    
    MOV AH, 06H             ; Scroll up window
    MOV AL, 00H             ; Screen scroll (clear)  
    MOV BX, SI              ; Screen attributes
    MOV CX, DI              ; Top-left corner
    MOV DX, 184FH           ; Bottom-right corner: DH = 24, DL = 79
    INT 10H
    
    POPA                    ; Restore saved values   
    RET        
RECT_DRAW ENDP

; Procedure for prompting user to press any key
ANY_KEY PROC
    PUSHA                   ; Save register values to be clobbered
    
    ; Hide cursor
    MOV AH, 01H
    MOV CH, 0010_0000B      ; Bit 5 set to 1 (invisible)   
    INT 10H
    
    ; Print interstitial text
    MOV DX, OFFSET TEXT4
    MOV CX, 0171BH          ; At (23, 27)
    CALL DISP_MESS   
    
    ; Awaiting input
    wait_input:
        ; Check keystroke from buffer
        MOV AH, 01H         ; ZF = 0 if keystroke available     
        INT 16H             
        JNZ break_wait
        
        ; Check mouse clicks
        MOV AX, 03H         ; BX = 1 when left click, BX = 2 when right click
        INT 33H             
        CMP BX, 0
        JNZ break_wait       
                
        ; If no input, then repeat loop
        JMP wait_input    
    break_wait:
    
    POPA                    ; Restore saved values
    RET
ANY_KEY ENDP
     