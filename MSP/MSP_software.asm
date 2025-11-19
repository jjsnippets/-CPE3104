; CPE 3104 - MICROPROCESSORS
; Group 4   TTh 4:30 PM - 7:30 PM LBCEAC2 TC
; T1-2 RTX 6090
; Ayabe, Kaishu; Fernandez, Schumacher Jaryl; Perez, Julio Miguel; Sarcol, Joshua
; Mini Simulation Project

; Case Study 2: Environment Sensor
; Being informed about the environment is important in our daily lives. Temperature,
; humidity and airpressure are key variables that affect the weather and our temper.
; The user can set a unit of measuring the temperature (Celsius or Fahrenheit) and
; pressure (atm or mb). The display updates in real-time to change in temperature,
; pressure and humidity.

DATA    SEGMENT
    ORG 03000H
                             
DATA    ENDS

STACK   SEGMENT PARA STACK
    DW 64 DUP(?)            ; Reserve 64 words for stack
TOS DW ?                    ; Top of stack marker
STACK   ENDS

; INTERRUPT HANDLERS HERE
;HANDLER0    SEGMENT
;ISR0    PROC FAR
;    ASSUME CS:HANDLER0, DS:DATA, SS:STACK
;    ORG 01000H    
; 
;ISR0    ENDP
;HANDLER0    ENDS

CODE    SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK
    ORG 08000H
START:

HLT             
CODE    ENDS
        END START
 