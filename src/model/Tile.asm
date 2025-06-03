    module Tile

spritePatternOffsetA:   equ 8
asciiPatternOffset:     equ 'A' - spritePatternOffsetA

MAX_COLUMN:                equ 15

;-----------------------------------------------------------------------------------
;
; Convert letter to spriteItem
;
; In: 
;     A - letter  
;     IX - pointer to spriteItem struct
;
; Out:
;     IX - pointer to next spriteItem struct
;
;-----------------------------------------------------------------------------------
letterToSprite:
    ; keep bc clean
    push bc
    ; convert the letter to its sprite pattern
    sub asciiPatternOffset
    ld (ix + spriteItem.pattern),a
    
    ld a, (nextSpriteId)
    ld (ix + spriteItem.id),a

    ; Each column is 16 pixels, so need to multiply column by 16
    ; also add 32 as columns do not use the border
    ; y = col * 16 + 32 = (col + 2) * 16
    ld a,(letterColumn)
    inc a : inc a
    rla : rla : rla : rla
    ld (ix + spriteItem.y),a

    ; Each row is 16 pixels, so need to multiply row by 16
    ; also add 32 as rows do not use the border
    ; y = row * 16 + 32 = (row + 2) * 16
    ld a,(letterRow)
    inc a : inc a
    rla : rla : rla : rla
    ld (ix + spriteItem.x),a
    ; Copy carry flag into x's high byte
    ld a,0
    adc a
    ld (ix + spriteItem.x + 1),a

    ld bc,spriteItem

    add ix,bc
    pop bc
    ret



;-----------------------------------------------------------------------------------
;
; Convert word to a list of spriteItems
;
; In: 
;     HL - pointer to letters
;     IX - pointer to start of sprite data
;
; Out:
;     IX - pointer to next spriteItem struct
;
;-----------------------------------------------------------------------------------
wordToSprites:
.next:
    ld a,(hl)
    jr z, .finished
    call letterToSprite
    call nextColumn
    inc hl
    jr .next
.finished:
    ret

nextColumn:
    ld a,(letterRow)
    cp MAX_COLUMN
    jr z, .nextRow
    ld a,(letterColumn)
    inc a
    ld (letterColumn),a
    ld a,255
.nextRow:
    inc a
    ld (letterRow),a
    ret


nextSpriteId:
    db 1
letterRow:
    db 5
letterColumn:
    db 10



    endmodule