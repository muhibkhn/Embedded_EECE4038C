#include "p16f886.inc"

; CONFIG1
; Configuration word for CONFIG1: 0x20D4
  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
; Configuration word for CONFIG2: 0x3EFF
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

; Place code below this line
PwrOnRst    CODE    0x0	; Execution begins at address 0 after power on
    goto Main		; Branch to the 'Main' subroutine to begin execution

IntVect	    CODE    0x4	; Interrupt code must be placed at address 0x4
    goto Interrupt	; Left blank for now, there are no interrupts to service

UsrCode	    CODE	    ; User code space. Not providing an address allows the assembler to place it where it thinks most convenient

Cblock
    D1
    D2
EndC

;;;; THE FOLLOWING DECREASES CLOCK SPEED TO 2MHZ ;;;;
banksel OSCCON
movlw   B'01010001'
movwf   OSCCON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
	banksel ANSELH
	clrf    ANSELH	    ; Set all I/O on PORTB to digital (0 or 1)
	
	banksel INTCON
	bcf	INTCON, 7   ; Clear Global Interrupt Enable bit
	
	;;;; PORT B ;;;;
	banksel TRISB	
	clrf    TRISB	    ; Set all I/O on PORTB to output
	movlw   B'00100000'
	movwf   TRISB       ; Pin RB5 is input
	
	;;;; Interrupt ;;;;
	banksel IOCB	    ; Interrupt on change register
	bsf	IOCB, 5
	
	banksel INTCON
	bsf	INTCON, 7
	bsf	INTCON, 3
	;movlw B'11001000'
	;movwf   INTCON
	
	banksel PORTB
    clrf    PORTB	    ; Initialize port for use
	
	goto	main_loop
	
main_loop:
	bcf	PORTB, 0
	bcf	PORTB, 1
	bcf	PORTB, 2
	bsf	PORTB, 3
	goto	main_loop
    
Interrupt:
	bcf	PORTB, 3
	bsf	PORTB, 0
	call	NO_OP
 	call	NO_OP

	bcf	PORTB, 0
	bsf	PORTB, 1
	call	NO_OP
	call	NO_OP

	bcf	PORTB, 1
	bsf	PORTB, 2
	call	NO_OP
	call	NO_OP

	bcf	PORTB, 2
	bsf	PORTB, 3
	call	NO_OP
	call	NO_OP

	bcf	PORTB, 3
	banksel	INTCON
	bcf	INTCON, 0    ; Clear interrupt flag
	retfie
	
NO_OP:
	nop
	decfsz D1, 1 ;1
	goto $-1
	
	nop
	nop
	decfsz D2, 1 ;1
	goto NO_OP
	return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
