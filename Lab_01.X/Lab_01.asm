; Assembly source line config statements
#include "p16f886.inc"

; CONFIG1
; __config 0x20D4
  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
; CONFIG2
; __config 0x3EFF
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
 

; Place code below this line
PwrOnRst    CODE    0x0     ; Execution begins at address 0 after power on
    goto Main               ; Branch to main to begin execution

IntVect     CODE    0x4     ; Interrupt code must be placed at address 0x4
    ; Left blank for now, there are no interrupts to service

UsrCode     CODE            ; User code space. Not providing an address allows the
                            ;   assembler to place it where it thinks most
                            ;   convenient
Main:
    banksel	ANSELH	; Tell the assembler to access the memory back this
    clrf	ANSELH	; Set all I/O on PORTB to digital (0 or 1) 
    banksel     TRISB           ; Selects bank containing register TRISB
    clrf        TRISB           ; All port B pins are configured as outputs
    movlw       b'00100000'
    movwf       TRISB           ; Pin RA1 is input
    banksel     PORTB           ; Selects bank containing register TRISB
    clrf        PORTB
Off:
    bcf PORTB, 3
    btfss PORTB, 5           ; Check if S1 (bit 5 of PORTB) is pressed
    goto On
    goto Off
On:
    
    bsf PORTB, 3
    btfss PORTB, 5           ; Check if S1 (bit 5 of PORTB) is pressed
    goto Off
    goto On

    end