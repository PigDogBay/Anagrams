    module Tile

SPRITE_PATTERN_OFFSET_A:    equ 8
ASCII_PATTERN_OFFSET:       equ 'A' - SPRITE_PATTERN_OFFSET_A
SLOT_SPRITE_PATTERN:        equ 6

LAYOUT_TILE_START_ROW:      equ 10
LAYOUT_TILE_START_COLUMN:   equ 5
LAYOUT_SLOT_START_ROW:      equ 2
LAYOUT_SLOT_START_COLUMN:   equ 5
LAYOUT_TILE_CENTER_COLUMN:  equ 10

CHAR_SPACE:                 equ " "
CHAR_NEWLINE:               equ "\n"
CHAR_END:                   equ "."

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
; struct: tileStruct
; 
; 
; 
;-----------------------------------------------------------------------------------
    struct @tileStruct
id          byte
letter      byte
    ends

;-----------------------------------------------------------------------------------
; 
; struct: slotStruct
; 
; .tileId is the slotted tile ID, if 0 then this indicates no tile has been slotted
; .letter is the expected letter, 
; .id id of the slot
; 
; 
;-----------------------------------------------------------------------------------
    struct @slotStruct
id          byte
letter      byte
tileId      byte
    ends

;-----------------------------------------------------------------------------------
;
; Function: removeAll()
;
; Sets slot and tile count to 0
;
; Dirty: A, HL 
;
;-----------------------------------------------------------------------------------
removeAll:
    ;reset variables
    xor a
    ld (tileCount),a
    ld (slotCount),a
    ret

;-----------------------------------------------------------------------------------
;
; Function: createSlotsTiles(uint8 id, uint16 ptr) -> uint8 nextId
; 
; Sets up the tile and slot lists from the puzzle data
; 
; In: 
;     C - gameId of the first item
;     HL - pointer to puzzle data
;
; Out C - gameId advanced ready for next game item
;
; Dirty: A, BC, HL, DE, IX, IY
;
;-----------------------------------------------------------------------------------
createSlotsTiles:
    ld ix, tileList
    ld iy, slotList
    ;Cancel out the first time inc hl
    dec hl
.nextLetter:
    inc hl
    ld a,(hl)

    cp CHAR_SPACE
    jr z,.whiteSpace

    cp CHAR_NEWLINE
    jr z,.whiteSpace

    cp CHAR_END
    jr z,.exit

    ;new tile
    ld (ix+tileStruct.id),c
    ld (ix+tileStruct.letter),a
    ld de,tileStruct
    add ix,de
    ;advance gameId
    inc c

    ;new slot
    ld (iy+slotStruct.id),c
    ld (iy+slotStruct.letter),a
    ld (iy+slotStruct.tileId),0
    ld de,slotStruct
    add iy,de
    ;advance gameId
    inc c

    ld a, (tileCount)
    inc a
    ld (tileCount),a

    ld a, (slotCount)
    inc a
    ld (slotCount),a

    jr .nextLetter

.whiteSpace:    
    ; Add a spacer slot
    ld (iy+slotStruct.id),0
    ld (iy+slotStruct.letter),a
    ld (iy+slotStruct.tileId),0
    ld de,slotStruct
    add iy,de

    ld a, (slotCount)
    inc a
    ld (slotCount),a
    jr .nextLetter

.exit:
    ; ;Remove trailing spacer slot
    ; ld a, (slotCount)
    ; dec a
    ; ld (slotCount),a

    ret


;-----------------------------------------------------------------------------------
;
; Function: tileToSprite(uint16 ptrSprite, uint16 ptrTile)
;
; Convert tileStruct to a spriteItem
;
; In: IX - pointer to spriteItem struct
;     IY - pointer to tileStruct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
tileToSprite:
    ;Use tile ID as game ID
    ld a,(iy + tileStruct.id)
    ld (ix + spriteItem.gameId),a

    ; convert the letter to its sprite pattern
    ld a,(iy + tileStruct.letter)
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
; Function: tilesToSprites()
;
; Add all the items in the tile list to the sprite list
;
; Dirty A, IX, IY
;
;-----------------------------------------------------------------------------------
tilesToSprites:
    push bc
    push de

    ;init vars for layout
    ld a, LAYOUT_TILE_START_ROW
    ld (letterRow),a
    ld a, LAYOUT_TILE_START_COLUMN
    ld (letterColumn),a

    ld a, (tileCount)
    ld b, a
    ld iy, tileList
    ld de,tileStruct
.nextTile:
    ; Create a spriteItem, returns IX ptr to spriteItem 
    call SpriteList.reserveSprite
    ; Takes IX, IY
    call tileToSprite
    call tilesLayout
    ; point to the next tile
    add iy,de

    djnz .nextTile

    pop de
    pop bc
    ret





;-----------------------------------------------------------------------------------
;
; private function tilesLayout()
;   helper function to layout the tiles
; 
; Dirty A
; 
;-----------------------------------------------------------------------------------
tilesLayout:
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
; Function: slotToSprite(uint16 ptrSprite, uint16 ptrSlot)
;
; Convert slotStruct to a spriteItem
;
; In: IX - pointer to spriteItem struct
;     IY - pointer to slotStruct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
slotToSprite:
    ;Use tile ID as game ID
    ld a,(iy + slotStruct.id)
    ld (ix + spriteItem.gameId),a

    ld (ix + spriteItem.pattern),SLOT_SPRITE_PATTERN
    
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
; Function: slotsToSprites()
;
; Add all the items in the slot list to the sprite list
;
; Dirty A, IX, IY
;
;-----------------------------------------------------------------------------------
slotsToSprites:
    push bc
    push de

    ;init vars for layout
    ld a, LAYOUT_SLOT_START_ROW
    ld (letterRow),a
    ld a, LAYOUT_SLOT_START_COLUMN
    ld (letterColumn),a

    ld a, (slotCount)
    ld b, a
    ld iy, slotList
    ld de,slotStruct
.nextSlot:
    ;Skip over spacer slots, but leave a space
    ld a,(iy + slotStruct.letter)
    cp CHAR_SPACE
    jr z, .spacer

    cp CHAR_NEWLINE
    jr z, .newLine

    ; Create a spriteItem, returns IX ptr to spriteItem 
    call SpriteList.reserveSprite
    ; Takes IX, IY
    call slotToSprite
.spacer:
    ; Next column
    ld a,(letterColumn)
    inc a
    ld (letterColumn),a

    ; point to the next slot
    add iy,de
    djnz .nextSlot
    jr .exit

.newLine:
    ld a,LAYOUT_TILE_START_COLUMN
    ld (letterColumn),a
    ld a,(letterRow)
    inc a
    ld (letterRow),a
    add iy,de
    djnz .nextSlot
    
.exit:
    pop de
    pop bc
    ret



;-----------------------------------------------------------------------------------
; 
; function justifySlots(uint16 ptr) -> uint8
; 
; Helper function to centre a line of slots
; 
; In: HL pointer to the start of the line in the anagram string 
; Out: A, column to place first slot of the line
; 
;-----------------------------------------------------------------------------------
justifySlots:
    ld a,CHAR_END
    call String.lenUptoChar
    ld b,a

    ld a,CHAR_NEWLINE
    call String.lenUptoChar

    ;find lowest index
    cp b
    ; If carry, new line found first
    jr c, .exit
    ; no newline, use fullstop index
    ld a,b

.exit:
    ; Halve the lenght, negate it and ad it to the center Column position
    sra a
    neg
    add LAYOUT_TILE_CENTER_COLUMN
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

; private variables Used by nextColumn()
letterRow:
    db 0
letterColumn:
    db 0


tileCount:
    db 0
tileList:
    block tileStruct * 64

slotCount:
    db 0
slotList:
    block tileStruct * 64

    endmodule