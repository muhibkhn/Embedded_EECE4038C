#include "p16f886.inc"   ; Include the header file for the PIC16F886 microcontroller.

; CONFIG1
; __config 0x20D4
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF

; CONFIG2
; __config 0x3EFF
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

; Place data below this line
DelayVars    UDATA
Count1       res   0x1
Count2       res   0x1
Count3       res   0x1

; Place code below this line
PwrOnRst    CODE    0x0    ; Execution begins at address 0 after power on
goto Main    ; Branch to the 'Main' subroutine to begin execution

IntVect     CODE    0x4    ; Interrupt code must be placed at address 0x4
; Left blank for now, as there are no interrupts to service

UsrCode     CODE    ; User code space. Not providing an address allows the
; assembler to place it where it thinks most
; convenient

Main:
    call Init  ; Call the 'Init' subroutine
MainLoop:
    call ToggleLED  ; Call the 'ToggleLED' subroutine
    call delay     ; Call the 'delay' subroutine
    goto MainLoop  ; Go back to the 'MainLoop' subroutine

Init:
    banksel ANSELH    ; Tell the assembler to access the memory bank where 'ANSELH' is found
    clrf ANSELH       ; Set all I/O on PORTB to digital (0 or 1)

    banksel TRISB      ; Access the 'TRISB' memory bank
    clrf TRISB         ; Set all I/O on PORTB to output

    banksel PORTB      ; Access the 'PORTB' memory bank
    clrf PORTB
    bcf PORTB, 3      ; Clear bit 3 of PORTB (Led DS4 is initially off)

    banksel OSCCON     ; Access the 'OSCCON' memory bank
    movlw b'01110001'  ; Load the binary value 01110001 into the working register
    movwf OSCCON       ; Store the value in the 'OSCCON' register to set the clock rate to 8 MHz

    banksel Count1    ; Access the 'Count1' memory bank
    clrf Count1       ; Clear 'Count1'
    clrf Count2       ; Clear 'Count2'
    movlw 0xB4        ; Load 0xB4 into the working register (Binary VAL 180)
    movwf Count2      ; Store it in 'Count2'
    clrf Count3       ; Clear 'Count3'
    movlw 0x6         ; Load 0x6 into the working register
    movwf Count3      ; Store it in 'Count3'
    return

ToggleLED:
    banksel PORTB      ; Access the 'PORTB' memory bank
    movlw 0x8          ; Load 0x8 into the working register
    xorwf PORTB, 1     ; XOR the value in 'PORTB' with 0x8 to toggle the LED
    return

delay:
    banksel Count1    ; Access the 'Count1' memory bank
DelayLoop:
    decfsz Count1, 1   ; Decrement 'Count1' and skip the next instruction if it becomes zero
    goto DelayLoop      ; If 'Count1' is not zero, repeat the loop
    decfsz Count2, 1   ; Decrement 'Count2' and skip the next instruction if it becomes zero
    goto DelayLoop      ; If 'Count2' is not zero, repeat the loop
    movlw 0xB4         ; Load 0xB4 into the working register (Binary VAL 180)
    movwf Count2       ; Store it in 'Count2'
    decfsz Count3, 1   ; Decrement 'Count3' and skip the next instruction if it becomes zero
    goto DelayLoop      ; If 'Count3' is not zero, repeat the loop
    movlw 0x6          ; Load 0x6 into the working register
    movwf Count3       ; Store it in 'Count3'
    return

end  ; End of the program
