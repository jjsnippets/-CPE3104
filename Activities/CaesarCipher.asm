; CPE 3104 - MICROPROCESSORS
; Group 3   TTh 4:30 PM - 7:30 PM LBCEAC1 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/10/15
; Assignment | Caesar Cipher

; Write an assembly language program that will apply a
; Caesar Cipher to a string in memory. Use a right shift
; of 3. Write the encrypted string in memory. 

SZ EQU 63                   ; Number of characters in the string
                            ; Manually change this value if the length of the string is changed

ORG 100H                    ; Emulator set-up

.data                       ; Start of data segment
PLNTX DB    SZ, 'This is the string to be encrypted ABCDEFGHIJKLM*NOPQRSTUVWXYZ$'
CPHTX DB    SZ, SZ DUP(' ') 
; '$' as delimeter, so that plaintext, ciphertext, and code
; is easier to differntiate in memory
; Also accomodates 21H/09H interrupt printing if desired
 
.code                       ; Start of code segment
; Copy PLNTX to CPHTX 
    MOV CX, SZ              ; Copy SZ amount of bytes (characters) 
    INC CX                  ; (Include the $ delimeter)
    MOV SI, OFFSET PLNTX    ; From memory address PLNTX
    MOV DI, OFFSET CPHTX    ; To memory address CPHTX
    REP MOVSB               ; Repeat indivual MOV operations SZ + 1 times

; Initial set-up for the loop
    MOV BX, SZ              ; Decrementer
    MOV DI, OFFSET CPHTX    ; Memory location of the ciphertext string

; Loop SZ times    
; Starting at the last character
letter_shift:
; "for loop" logic
    DEC BX                  ; First: exclude the $ delimeter
                            ; Succeeding: next character to check
    
    CMP BX, 0               ; If there are no more letters to encrypt
    JE term                 ; Then exit from loop

; Check if the character is a letter    
    MOV AH, [DI + BX]       ; Current character to check    
    AND AH, 11_000000B      ; Inspect the 2 MSBs
    XOR AH, 01_000000B      ; If it does not conform to this bit pattern   
    JNZ letter_shift        ; Then it is certainly not a letter character
    
    MOV AL, [DI + BX]       ; Current character to check
    AND AL, 000_11111B      ; Inspect the 5 LSBs
    JZ letter_shift         ; If value is 0 (not A), then not a letter    
    CMP AL, 26              ; If value is greater than 26 (beyond Z)
    JG letter_shift         ; Then not a letter

; After checking that the character is a letter (in AL),
; Apply a right shift of 3     
    ADD AL, 3               ; Shift letter 3 to the right

; Bounds checking and correction logic
    CMP AL, 26              ; If value is within bounds (Z is 26)
    JLE insert_letter       ; Then proceed to next procedure
    SUB AL, 26              ; Otherwise, "loop back" the value of character to 'A'
                            ; 27 => A   28 => B   29 => C       

; Change the plaintext letter to the encrypted letter    
    insert_letter:
        MOV AH, [DI + BX]   ; Grab the plaintext letter 
        AND AH, 111_00000B  ; Keep the 3 MSBs (6th bit is if uppercase/lowercase)
        OR AL, AH           ; OR with the encrypted value
                            ; Essentially "merges" the numeric value of the letter and its case
        MOV [DI + BX], AL   ; Insert the encrypted letter to the same spot in memory
    
    JMP letter_shift        ; Single letter has been encrypted
                            ; Repeat the loop

; Exit from program
term:
    HLT                     ; Terminate once finished
