; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/09/18
; LE2 | Addressing Modes

; Activity #1

; Code has been slightly altered to work under emu8086
ORG 100H    ; GLOBAL is not a recognized directive, so replaced with ORG  

JMP _start  ; Skip over data, to avoid decoding data bytes as opcodes                        

DATA1 DB 25H 
DATA2 DW 1234H  
DATA3 DB 0H  
DATA4 DW 0H 
DATA5 DW 2345H, 6789H 

_start:     ; No further changes after this line                     
    MOV AL, 25              ; COPY 25H INTO 8 BIT AL REGISTER 
    MOV AX, 2345            ; COPY 2345H INTO 16 BIT AX REGISTER 
    MOV BX, AX              ; COPY THE CONTENT OF AX INTO BX REGISTER (16 BIT) 
    MOV CL, AL              ; COPY THE CONTENT OF AL INTO CL REGISTER 
    MOV AL, DATA1           ; COPIES THE BYTE CONTENTS OF DATA SEGMENT MEMORY LOCATION 
                            ; DATA1 INTO 8 BIT AL 
    MOV AX, DATA2           ; COPIES THE WORD CONTENTS OF DATA SEGMENT MEMORY 
                            ; LOCATION DATA2 INTO 16 BIT AX 
    MOV DATA3, AL           ; COPIES THE AL CONTENT INTO THE BYTE CONTENTS OF DATA 
                            ; SEGMENT MEMORY LOCATION DATA3 
    MOV DATA4, AX           ; COPIES THE AX CONTENT INTO THE WORD CONTENTS OF DATA 
                            ; SEGMENT MEMORY LOCATION DATA4 
    MOV BX, OFFSET DATA5    ; THE 16 BIT OFFSET ADDRESS OF DS MEMEORY LOCATION DATA5 IS 
                            ; COPIED INTO BX 
    MOV AX, [BX]            ; COPIES THE WORD CONTENT OF DATA SEGMENT MEMORY LOCATION 
                            ; ADDRESSED BY BX INTO AX (REGISTER INDIRECT ADDRESSING) 
    MOV DI, 02H             ; ADDRESS ELEMENT 
    MOV AX, [BX+DI]         ; COPIES THE WORD CONTENT OF DATA SEGMENT MEMORY LOCATION 
                            ; ADDRESSED BY BX+DI INTO AX(BASE PLUS INDIRECT ADDRESSING)  
    MOV AX, [BX+0002H]      ; COPIES THE WORD CONTENT OF DATA SEGMENT (16 BIT) 
    MOV AL, [DI+2]          ; REGISTER RELATIVE ADDRESSING 
    MOV AX, [BX+DI+0002H]   ; COPIES THE WORD CONTENT OF DATA SEGMENT MEMORY LOCATION 
                            ; ADDRESSED BY BX+DI+0002H INTO AX (16 BIT) 
INT 20H
