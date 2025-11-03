; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; Ayabe, Kaishu; Sarcol, Joshua           BS-CpE 3        2025/11/03
; Assignment | Interfacing 8253 (Programmable Interval Timer)

; Create an assembly language program that will increment the count
; exactly one (1) second. When the count reaches 9, it will revert to 0
; AND continues. Configure the 8253 to generate the required delay (timeout).
; Using Proteus, create the schematic diagram of the entire 8086 computer
; system including the processor, address latch, data buffer, I/O address
; decoder, 8255 AND 8253, then, run simulate.

; High level approach
;   Load the time to wait into the 8253 counter
;   Wait for the terminal pin to go low
;   Increment counter by 1
;   If counter == 10, then reset to 0
;   Display digits
;   Wait until the terminal pin goes high
;   Repeat forever

ORG 100H
    DISPLAY_PORT    EQU 080H    ; 7-segment display (output)
    SIGNAL_PORT     EQU 082H    ; 8253 terminal output (input)
    COM_REG_8255    EQU 086H    ; 8255 Command register
    TIMER_PORT      EQU 088H    ; Counter 0
    COM_REG_8253    EQU 08EH    ; 8253 Command register
    SEC_DELAY_MSB   EQU 007H    ; 2000Hz (07B0H) 
    SEC_DELAY_LSB   EQU 0B0H

.code
; Set-up
    MOV CX, 0                   ; 0-9 counter
    
    ; Program the 8255
    MOV DX, COM_REG_8255
    MOV AL, 082H                ; 10000_010 (082H)
                                ; 1---- --- Command Group A
                                ; -00-- --- Mode 0 for PORTA
                                ; ---0- --- Output for PORTA
                                ; ----0 --- Output for PORTC7-4 (unused)
                                ; ----- 0-- Mode 1 for PORTB
                                ; ----- -1- Input for PORTB
                                ; ----- --0 Output for PORTC3-0 (unused)
    OUT DX, AL
    
    ; Set the displayed digit to 0
    MOV DX, DISPLAY_PORT
    MOV AL, 0H
    OUT DX, AL
    
    ; Program the 8353
    MOV DX, COM_REG_8253
    MOV AL, 038H                ; 00_11_100_0 (038H)
                                ; 00 -- --- - Clock 0
                                ; -- 11 --- - Read/Write from LSB, then MSB
                                ; -- -- 100 - Mode 4
                                ; -- -- --- - Binary
    OUT DX, AL
    
; Load the time to wait into the 8253 counter
start_load:
    MOV DX, TIMER_PORT
    MOV AL, SEC_DELAY_LSB
    OUT DX, AL
    
    MOV AL, SEC_DELAY_MSB
    OUT DX, AL   
      
poll_loop:
; Wait for the terminal pin to go low
    MOV DX, SIGNAL_PORT
    IN AL, DX
    
    CMP AL, 0
    JNZ poll_loop
    
; Increment counter by 1
    INC CX

; If counter == 10, then reset to 0
    CMP CX, 10
    JNE not_ten
    MOV CX, 0
    not_ten:
    
; Display digits
    MOV DX, DISPLAY_PORT
    MOV AL, CL
    OUT DX, AL
    
; Wait until the terminal pin goes high
wait_loop:
    MOV DX, SIGNAL_PORT
    IN AL, DX
    
    CMP AL, 1
    JNZ wait_loop  
       
; Repeat forever
    JMP start_load