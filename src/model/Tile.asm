    module Tile

SPRITE_PATTERN_OFFSET_A:    equ 8
ASCII_PATTERN_OFFSET:       equ 'A' - SPRITE_PATTERN_OFFSET_A

MAX_COLUMN:                 equ 15

;-----------------------------------------------------------------------------------
;
; Convert letter to spriteItem
;
; In: 
;     A - letter  
;     IX - pointer to spriteItem struct
;
;-----------------------------------------------------------------------------------
letterToSprite:
    ; convert the letter to its sprite pattern
    sub ASCII_PATTERN_OFFSET
    ld (ix + spriteItem.pattern),a
    
    ; Each row is 16 pixels, so need to multiply row by 16
    ; also add 32 as rows do not use the border
    ; y = row * 16 + 32 = (row + 2) * 16
    ld a,(letterRow)
    inc a : inc a
    rla : rla : rla : rla
    ld (ix + spriteItem.y),a

    ; Each column is 16 pixels, so need to multiply column by 16
    ; also add 32 as columns do not use the border
    ; y = col * 16 + 32 = (col + 2) * 16
    ld a,(letterColumn)
    inc a : inc a
    rla : rla : rla : rla
    ld (ix + spriteItem.x),a
    ; Copy carry flag into x's high byte
    ld a,0
    adc a
    ld (ix + spriteItem.x + 1),a
    ret



;-----------------------------------------------------------------------------------
;
; Convert word to a list of spriteItems
;
; In: 
;     HL - pointer to letters
;
;
;-----------------------------------------------------------------------------------
wordToSprites:
.next:
    ld a,(hl)
    cp 0
    jr z, .finished
    call SpriteList.reserveSprite
    ; A is dirty so reload character
    ld a,(hl)
    call letterToSprite
    call nextColumn
    ; Next Letter
    inc hl
    jr .next
.finished:
    ret


nextColumn:
    ld a,(letterColumn)
    cp MAX_COLUMN
    jr nz, .noColumnOverflow
    ; Increase row
    ld a,(letterRow)
    inc a
    ld (letterRow),a
    ; 0 column
    ld a,255
.noColumnOverflow:
    inc a
    ld (letterColumn),a
    ret


nextSpriteId:
    db 1
letterRow:
    db 10
letterColumn:
    db 5



    endmodule