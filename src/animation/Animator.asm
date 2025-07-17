;-----------------------------------------------------------------------------------
; 
; Module: Twisted Animator
; 
; Handles all the animation types and state
; 
; 
;-----------------------------------------------------------------------------------

    module Animator

BIT_FLASH: equ 0

update:
    ld a,(finishedFlags)

    bit BIT_FLASH,a
    call z, Flash.update

    ret

;-----------------------------------------------------------------------------------
; 
; Field: finishedFlags
; 
; Each bit tracks the state of a particular animation, is it finished (1) or running (0)
; 
;-----------------------------------------------------------------------------------
finishedFlags:
    db %11111111

    endmodule
