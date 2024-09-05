#include "p16f886.inc"

; CONFIG1
; __config 0x20D4
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
; __config 0x3EFF
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

; Place code below this line
PwrOnRst CODE 0x0 ; Execution begins at address 0 after power on
    goto Main ; Branch to main to begin execution

IntVect CODE 0x4 ; Interrupt code must be placed at address 0x4
    ; Left blank for now, there are no interrupts to service

UsrCode CODE ; User code space. Not providing an address allows the
            ; assembler to place it where it thinks most
            ; convenient

Cblock
    D1
    D2
EndC

Main:
    banksel ANSELH ; Tell the assembler to access the memory bank where
                   ; ANSELH register is found. This is not an instruction
                   ; that is executed but an assembler directive
    clrf ANSELH ; Set all I/O on PORTB to digital (0 or 1)

    ;;;; THE FOLLOWING DECREASES CLOCK SPEED TO 2MHZ ;;;;
    banksel OSCCON
    movlw B'01010001' ; Load the value B'01010001' into WREG
    movwf OSCCON ; Store the value in WREG into the OSCCON register
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;; PORT B ;;;;;;;
    banksel TRISB
    clrf TRISB ; Clear all bits in TRISB to set them as outputs
    movlw B'00100000' ; Load the value B'00100000' into WREG
    movwf TRISB ; Set RB5 as an input by writing the value in WREG to TRISB

    ;;;;;;; PORT E ;;;;;;;
    banksel TRISE
    clrf TRISE ; Clear all bits in TRISE to set them as outputs
    movlw B'00001000' ; Load the value B'00001000' into WREG
    movwf TRISE ; Set RE3 as an input by writing the value in WREG to TRISE
    ;;;;;;;;;;;;;;;;;;;;;;

    banksel PORTB
    clrf PORTB ; Clear all bits in PORTB to initialize it
    goto main_loop

main_loop:
    bsf PORTB, 0 ; Set bit 0 of PORTB
    bcf PORTB, 3 ; Clear bit 3 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    btfss PORTE, 3 ; Test if bit 3 of PORTE is clear (skip if set)
    goto DS1_func ; Jump to DS1_func if bit 3 is clear
    btfss PORTB, 5 ; Test if bit 5 of PORTB is clear (skip if set)
    goto DS4_func ; Jump to DS4_func if bit 5 is clear
    goto main_loop ; Continue looping if neither condition is met

DS1_func:
    bsf PORTB, 0 ; Set bit 0 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    bcf PORTB, 0 ; Clear bit 0 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    btfss PORTB, 5 ; Test if bit 5 of PORTB is clear (skip if set)
    goto both_func ; Jump to both_func if bit 5 is clear
    btfss PORTE, 3 ; Test if bit 3 of PORTE is clear (skip if set)
    goto main_loop ; Jump back to main_loop if bit 3 is clear
    goto DS1_func ; Continue DS1_func if neither condition is met

DS4_func:
    bsf PORTB, 3 ; Set bit 3 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    bcf PORTB, 3 ; Clear bit 3 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    btfss PORTE, 3 ; Test if bit 3 of PORTE is clear (skip if set)
    goto both_func ; Jump to both_func if bit 3 is clear
    btfss PORTB, 5 ; Test if bit 5 of PORTB is clear (skip if set)
    goto main_loop ; Jump back to main_loop if bit 5 is clear
    goto DS4_func ; Continue DS4_func if neither condition is met

both_func:
    bsf PORTB, 3 ; Set bit 3 of PORTB
    bsf PORTB, 0 ; Set bit 0 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    bcf PORTB, 3 ; Clear bit 3 of PORTB
    bcf PORTB, 0 ; Clear bit 0 of PORTB
    call NO_OP ; Call the NO_OP subroutine
    ;;;; NEED TO CHECK FOR BOTH BUTTON ;;;;;
    btfss PORTB, 5 ; Test if bit 5 of PORTB is clear (skip if set)
    goto DS1_func ; Jump to DS1_func if bit 5 is clear
    btfss PORTE, 3 ; Test if bit 3 of PORTE is clear (skip if set)
    goto DS4_func ; Jump to DS4_func if bit 3 is clear
    goto both_func ; Continue both_func if neither condition is met

NO_OP:
    nop ; No operation (delay)
    decfsz D1, 1 ; Decrement D1 and skip next instruction if result is zero
    goto $-1 ; Jump to the previous NOP instruction if D1 is not zero

    nop ; No operation (delay)
    nop ; No operation (delay)
    decfsz D2, 1 ; Decrement D2 and skip next instruction if result is zero
    goto NO_OP ; Jump to the NO_OP subroutine if D2 is not zero
    return ; Return from subroutine

; Needed for compilers to indicate the end of the program code
; It's a directive so needs to be inline with the code
end
