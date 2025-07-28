;-----------------------------------------------------------------------------------
; 
; Module: Twisted Animator
; 
; Handles all the animation types and state
; 
; 
;-----------------------------------------------------------------------------------

    module Animator

BIT_FLASH:              equ 0
BIT_FLASHTWO:           equ 1
BIT_FLASH_SPRITES:      equ 2
BIT_MOVE:               equ 3
BIT_APPEAR:             equ 4

update:
    ld a,(finishedFlags)
    bit BIT_FLASH,a
    call z, Flash.update

    ld a,(finishedFlags)
    bit BIT_FLASHTWO,a
    call z, FlashTwo.update

    ld a,(finishedFlags)
    bit BIT_FLASH_SPRITES,a
    call z, FlashSprites.update

    ld a,(finishedFlags)
    bit BIT_MOVE,a
    call z, MoveSprites.update

    ld a,(finishedFlags)
    bit BIT_APPEAR,a
    call z, Appear.update

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
