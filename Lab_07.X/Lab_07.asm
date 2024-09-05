#include "p16f886.inc"

; CONFIG1
; __config 0x20D4
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
; __config 0x3EFF
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

; All variables needed
Vars UDATA
    Count1  res 1 ; used for debounce
    Count2  res 1 ; used for debounce
    currInput res 1 ; used for current input number
    num1 res 1 ; used for storing 1st number
    num2 res 1 ; used for storing 2nd number
    oper res 1 ; used for storing the operation to perform
    result res 1 ; used for storing the result
    interNum res 1 ; used for storing the number of interrupts

PwrOnRst CODE 0x0
    goto Init

IntVect CODE 0x7
    banksel interNum
    btfss   interNum, 0x0
    goto    firstPress
    btfss   interNum, 0x1
    goto    secondPress
    btfss   interNum, 0x2
    goto    thirdPress
    goto    fourthPress
    
    ; First Num Input Storage
    firstPress:
        call    Debounce
        banksel currInput
        movf    currInput, 0
        movwf   num1
        clrf    currInput
        bsf interNum, 0x0 ; set bit 0 in bitfield to 1
        banksel INTCON
        bcf INTCON, 0 ; Reset interrupt PORTB flag
        retfie

    ; Second Num Input Storage
    secondPress:
        call    Debounce
        banksel currInput
        movf    currInput, 0
        movwf   num2
        clrf    currInput
        bsf interNum, 0x1 ; set bit 1 in bitfield to 1
        banksel INTCON
        bcf INTCON, 0 ; Reset interrupt PORTB flag
        retfie

    ; Operation Input and Calculation of result
    ; and display number on LEDs
    thirdPress:
        call    Debounce
        banksel currInput
        movf    currInput, 0
        movwf   oper
        clrf    currInput

        btfsc   oper, 0x0 ;; addition
        goto    addition
        btfsc   oper, 0x1 ;; subtraction
        goto    subtraction
        ; If code makes it here, input is invalid
        ; clear oper reg, flash pattern, return
        movlw   0x5
        banksel PORTB
        movwf   PORTB
        call    Debounce
        call    Debounce
        movlw   0xa
        movwf   PORTB
        call    Debounce
        call    Debounce
        clrf    PORTB ; reset LED's
        
        banksel INTCON
        bcf INTCON, 0 ; Reset interrupt PORTB flag
        retfie

    addition:
        movf    num1, 0
        addwf   num2, 0 ; add num1 and 2 and store in W
        movwf   currInput
        banksel PORTB
        movwf   PORTB ; move result to LED
        
        bsf interNum, 0x2 ; set bit 2 in bitfield to 1
        banksel INTCON
        bcf INTCON, 0 ; Reset interrupt PORTB flag
        retfie

    subtraction:
        banksel PORTB
        clrf    PORTB
        movf    num2, 0
        subwf   num1, 0
        movwf   PORTB

        btfsc   PORTB, 0x5
        goto    subtraction
        retfie

    ; Reset Calculator for Next Inputs
    fourthPress:
        call    Debounce
        clrf    currInput
        clrf    interNum
        clrf    num1
        clrf    num2
        banksel INTCON
        bcf INTCON, 0 ; Reset interrupt PORTB flag
        call Debounce
        retfie

UsrCode CODE
Init:
    ; Clock Rate Kept at Default 4 MHz
    
    ; Port B Config
    banksel ANSELH
    clrf ANSELH ; Make analog select digital I/O
    banksel TRISB
    clrf TRISB
    bsf TRISB, 5 ; Set RB5 as input
    banksel PORTB
    clrf PORTB ; Init PortB

    ; Port E Config
    banksel ANSEL
    clrf ANSEL ; Set PortE for digital I/O
    banksel TRISE
    clrf TRISE
    bsf TRISE, 3 ; Set RE3 as input
    banksel PORTE
    clrf PORTE ; Init PortE

    ; Interrupt Config
    banksel IOCB
    bsf IOCB, 0x05
    banksel INTCON
    clrf INTCON
    bsf INTCON, 7 ; GIE
    bsf INTCON, 3 ; RBIE
    bcf INTCON, 0 ; RBIF

    ; Init Variables
    banksel Count1
    clrf Count1
    clrf Count2
    clrf currInput
    clrf num1
    clrf num2
    clrf oper
    clrf interNum
    goto initDebounce

initDebounce:
    ; Fix  SW1 press on startup due to Vpp being directly
    ; connected to RE3 which is connected to SW1
    call Debounce 
    goto Main

Main:
    banksel PORTE
    btfss PORTE, 3
    call SW1_Pressed
    banksel currInput
    movf currInput, 0
    movwf PORTB
    goto Main

SW1_Pressed:
    call Debounce
    btfsc interNum, 0x2
    return ; Don't do anything when SW1 is pressed if waiting on fourth interrupt
    banksel currInput
    incf currInput, 1
    btfsc currInput, 0x3
    call inputOverflow
    return

; If currInput becomes 8, roll over
inputOverflow:
    banksel currInput
    clrf currInput
    return

; Used to debounce the button presses
Debounce:
    banksel Count1
DeBounceLoop:
    decfsz Count1, f
    goto DeBounceLoop
    decfsz Count2, f
    goto DeBounceLoop
    return

end