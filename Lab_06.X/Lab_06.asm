; Assembly source line config statements
#include "p16f886.inc"

; CONFIG1
; Configure oscillator, watchdog timer, power-up timer, reset, code protection, and more
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
; Configure brown-out reset voltage and write protection
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

; All variables needed
Vars    UDATA
Count1 res 1    ; used for debounce loop
Count2 res 1    ; used for debounce loop
;LEDdisp res 1  ; used for immediate display to LEDs (commented out)
currInput res 1    ; used for storing the current number (incremented with each SW1 press)
num1 res 1    ; used for storing the 1st number
num2 res 1    ; used for storing the 2nd number
interNum res 1    ; used for storing the number of interrupts

; Program entry point after power-on reset
PwrOnRst    CODE    0x0
    goto Init

; Interrupt vector
IntVect	    CODE    0x4
    banksel interNum
    btfss interNum, 0x0
    goto first
    btfss interNum, 0x1
    goto second
    goto third
    
    ; Store the first number in the first interrupt
    first:
    call Debounce
    banksel currInput
    movf currInput, 0
    movwf num1
    clrf currInput
    bsf interNum, 0x0 ; set bit 0 in the bitfield to 1
    banksel INTCON
    bcf INTCON, 0 ; Reset the interrupt PORTB flag
    retfie
    
    ; Store the second number, calculate the result, and display the number on LEDs	
    second:
    call Debounce
    banksel currInput
    movf currInput, 0
    movwf num2
    clrf currInput
    addwf num1, 0 ; add num1 with num2 and store in W
    movwf currInput
    ;movwf LEDdisp (commented out)
    banksel PORTB
    movwf PORTB ; Move the result into LEDs
    bsf interNum, 0x1 ; set bit 1 in the bitfield to 1
    banksel INTCON
    bcf INTCON, 0 ; Reset the interrupt PORTB flag
    retfie

    third:
    call Debounce
    clrf currInput
    ;clrf LEDdisp (commented out)
    clrf interNum
    clrf num1
    clrf num2
    banksel INTCON
    bcf INTCON, 0 ; Reset the interrupt PORTB flag
    call Debounce
    retfie

UsrCode	    CODE
Init:
    ; Set the clock rate to the default 4MHz

    ; Initialize SW2 and LEDs
    banksel ANSELH
    clrf ANSELH ; Make analog select digital I/O
    banksel TRISB
    clrf TRISB
    bsf TRISB, 5 ; Set RB5 as an input for SW2
    banksel PORTB
    clrf PORTB ; Initialize PortB

    ; Initialize SW1 as an input
    banksel ANSEL
    clrf ANSEL ; Set PortE for digital I/O
    banksel TRISE
    clrf TRISE
    bsf TRISE, 3 ; Set RE3 as an input for Sw1
    banksel PORTE
    clrf PORTE ; Initialize PortE

    ; Enable PORTB interrupts
    banksel IOCB
    bsf IOCB, 0x05
    banksel INTCON
    clrf INTCON
    bsf INTCON, 7 ; GIE (Global Interrupt Enable)
    bsf INTCON, 3 ; RBIE (PortB Change Interrupt Enable)
    bcf INTCON, 0 ; RBIF (Reset PortB Change Interrupt Flag)

    ; Initialize all variables to a start value
    banksel Count1
    clrf Count1
    clrf Count2
    ;clrf LEDdisp (commented out)
    clrf currInput
    clrf num1
    clrf num2
    clrf interNum

Main:
    call Debounce ; Fix phantom SW1 press on startup because of Vpp directly connected to RE3, which is connected to SW1

Main_loop:
    banksel PORTE
    btfss PORTE, 3
    call SW1_Pressed
    banksel currInput
    movf currInput, 0
    ;movwf LEDdisp (commented out)
    movwf PORTB
    goto Main_loop

SW1_Pressed:
    call Debounce
    btfsc interNum, 0x1
    return ; Don't do anything when SW1 is pressed if waiting on the third interrupt
    banksel currInput
    incf currInput, 1
    btfsc currInput, 0x3
    call inputOverflow
    return

; If currInput becomes 8, clear it to 0    
inputOverflow:
    banksel currInput
    clrf currInput
    return

; Used to debounce the button presses
; Used as a delay to eliminate button bounce and provide a pause before the button can turn it off
Debounce:
    banksel Count1
DeBounceLoop:
    decfsz Count1, f
    goto DeBounceLoop
    decfsz Count2, f
    goto DeBounceLoop
    return
end