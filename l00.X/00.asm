; Assembly source line config statements
#include "p16f886.inc"

; CONFIG1
; __config 0x20D4
  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

    
; CONFIG2
; __config 0x3EFF
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
 
; Place code below this line
PwrOnRst    CODE    0x0	; Execution begins at address 0 after power on
    goto Main		; Branch to main to begin execution
 
IntVect	    CODE    0x4	; Interrupt code must be placed at address 0x4
    ; Left blank for now, there is not interrupts to service
    
UsrCode	    CODE	; User code space. Not providing an address allows the
			;   assembler to place it where it thinks most
			;   convenient
Main:
    banksel ANSELH	; Tell the assembler to access the memory back this
			;   register is found on. This is not an instruction
			;   that is executed but an assembler directive
    clrf    ANSELH	; Set all I/O on PORTB to digital (0 or 1)
    
    banksel TRISB
    clrf    TRISB	; Set all I/O on PORTB to output
    
    banksel PORTB
    clrf    PORTB	; Initialize port for use
    
    bsf	    PORTB, 0x0	; Set LED 1 to on
    
LoopForever:		
    goto    LoopForever	; Will loop here until power reset

    ; Needed for compilers to indicate end of the program code
    ; Its a directive so needs to be inline with the code
    end