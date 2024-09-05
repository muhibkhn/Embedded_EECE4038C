#include "p16f886.inc"

; CONFIG1
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF


PwrOnRst    CODE    0x0    ; Execution begins at address 0 after power-on reset
    goto Init           ; Directs to the Init routine

IntVect        CODE    0x4 ; Interrupt code must be placed at address 0x4
    goto Interrupt    ; Directs to the Interrupt routine

UsrCode        CODE    ; User code space. Not providing an address allows the assembler to place it where it thinks most convenient

Init:
    ;;; Port B Config ;;;;
    banksel ANSELH
    clrf    ANSELH    ; Set all I/O on PORTB to digital 
    banksel TRISB
    clrf    TRISB     ; Set all I/O on PORTB to output
    banksel PORTB
    clrf    PORTB
    bcf     PORTB, 3  ; LED DS4 is initially off

    ;;;; Clock Config ;;;;
    banksel OSCCON
    movlw   b'0000001' ; Set the clock rate to 31 kHz
    movwf   OSCCON

    ;;;; Timer0 Config ;;;;
    banksel OPTION_REG ; Set Timer0 to Timer mode, assign a prescaler to Timer0, and set Prescaler rate to 1:16
    movlw   b'00000011'
    movwf   OPTION_REG
    banksel TMR0
    movlw   0xC ; Load 12 into the Timer register so that it ticks 244 times, (256 - 12 = 244 ticks)
    ; 0xC=12
    movwf   TMR0

    ;;;; Interrupt Config ;;;;
    banksel INTCON
    bsf     INTCON, 7   ; Enable GIE (Gobal interrupt bit)
    bsf     INTCON, 5   ; Enable T01E (Timer0 Overflow interrupt bit)
    goto Main

Main:
    goto Main

Interrupt:
    ;;;; LED Toggle ;;;;
    banksel PORTB
    xorwf   PORTB, 1    ; Toggle the second bit (bit 1) of PORTB
    bcf     PORTB, 2    ; Clear bit 2 of PORTB

    ;;;; Timer Reset / Flag Clear ;;;;
    banksel TMR0
    movlw   0xC         ; Load 12 (C in Hexadecimal) into the Timer register
    movwf   TMR0
    banksel INTCON
    bcf     INTCON, 2   ; Clear Timer0 interrupt flag
    retfie             ; Return from interrupt and enable global interrupts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end