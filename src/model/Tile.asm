    module Tile

SPRITE_PATTERN_OFFSET_A:    equ 8
ASCII_PATTERN_OFFSET:       equ 'A' - SPRITE_PATTERN_OFFSET_A

MAX_COLUMN:                 equ 15

DRAG_BOUNDS_X_MIN:               equ 16
DRAG_BOUNDS_X_MAX:               equ 319 - 16
DRAG_BOUNDS_X_MAX_LSB:           equ DRAG_BOUNDS_X_MAX - 256
DRAG_BOUNDS_X_MAX_IN_BOUNDS:     equ DRAG_BOUNDS_X_MAX - 1
DRAG_BOUNDS_X_MAX_LSB_IN_BOUNDS: equ DRAG_BOUNDS_X_MAX_IN_BOUNDS - 256
DRAG_BOUNDS_Y_MIN:               equ 16
DRAG_BOUNDS_Y_MAX:               equ 255 - 16
DRAG_BOUNDS_Y_MAX_IN_BOUNDS:     equ DRAG_BOUNDS_Y_MAX - 1

;-----------------------------------------------------------------------------------
;
; Function: letterToSprite 
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
; Function: wordToSprite
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




;-----------------------------------------------------------------------------------
;
; Function: boundsCheck
;
; Checks if the tile is in bounds, if not the tile X,Y is corrected to be back within 
; bounds. The Zero flag is set if the tile was out of bounds.
;
; In:   IX - pointer to spriteItem of the tile
; Out:  Z flag - Set out of bounds, not set in bounds
;
;-----------------------------------------------------------------------------------
boundsCheck:
    ; Test if x is negative
    ld a,(ix+spriteItem.x+1)
    bit 7,a
    jr nz, .outOfBoundsLowX

    ;If high byte is 1, then only check for max X
    cp 1
    jr z, .xMax

    ;Test x min
    ld a,(ix+spriteItem.x)
    cp DRAG_BOUNDS_X_MIN
    jr c, .outOfBoundsLowX
    jr .yMin
    
.xMax:
    ;Test x max
    ld a,(ix+spriteItem.x)
    cp DRAG_BOUNDS_X_MAX_LSB
    jr nc, .outOfBoundsHighX

.yMin:
    ;Test y min
    ld a,(ix+spriteItem.y)
    cp DRAG_BOUNDS_Y_MIN
    jr c, .outOfBoundsLowY

    ;Test y max
    cp DRAG_BOUNDS_Y_MAX
    jr nc, .outOfBoundsHighY

    ; clear sign flag
    or 1
    ret

.outOfBoundsLowX:
    ld (ix+spriteItem.x),DRAG_BOUNDS_X_MIN
    ld (ix+spriteItem.x+1),0
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsHighX:
    ld (ix+spriteItem.x),DRAG_BOUNDS_X_MAX_LSB_IN_BOUNDS
    ld (ix+spriteItem.x+1),1
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsLowY:
    ld (ix+spriteItem.y),DRAG_BOUNDS_Y_MIN
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsHighY:
    ld (ix+spriteItem.y),DRAG_BOUNDS_Y_MAX_IN_BOUNDS
    ; Set sign flag to indicate out of bounds
    xor a
    ret


nextSpriteId:
    db 1
letterRow:
    db 10
letterColumn:
    db 5



    endmodule