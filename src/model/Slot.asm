    module Slot


SLOT_SPRITE_PATTERN:        equ 6

LAYOUT_SLOT_START_ROW:      equ 1
LAYOUT_SLOT_CENTER_COLUMN:  equ 8



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
; Function: createSlots(uint8 id, uint16 ptr) -> uint8 nextId
; 
; Sets up the slot lists from the puzzle data
; 
; In: 
;     C - gameId of the first item
;     HL - pointer to puzzle data
;
; Out C - gameId advanced ready for next game item
;
; Dirty: A, BC, HL, DE, IY
;
;-----------------------------------------------------------------------------------
createSlots:
    ld de,slotStruct
    ld ix, slotList
    ; Prepend a newline slot, this will contain the column position
    call addNewLineSlot
.nextLetter:
    ld a,(hl)

    cp CHAR_SPACE
    jr z,.whiteSpace

    cp CHAR_NEWLINE
    jr z,.newLine

    or a
    jr z,.exit

    ;new slot
    ld (ix+slotStruct.id),c
    ld (ix+slotStruct.letter),a
    ld (ix+slotStruct.tileId),0
    add ix,de
    ;advance gameId
    inc c

    ld a, (slotCount)
    inc a
    ld (slotCount),a

    ;next letter
    inc hl
    jr .nextLetter

.whiteSpace:    
    ; Add a spacer slot
    ld (ix+slotStruct.id),0
    ld (ix+slotStruct.letter),CHAR_SPACE
    ld (ix+slotStruct.tileId),0
    add ix,de

    ld a, (slotCount)
    inc a
    ld (slotCount),a

    ;next letter
    inc hl
    jr .nextLetter

.newLine:    
    ;next letter
    inc hl
    call addNewLineSlot
    jr .nextLetter
.exit:

    ret

;-----------------------------------------------------------------------------------
;
; Function: addNewLineSlot(uint16 strPtr, uint16 slotPtr)
; 
; Helper function for createSlotTiles(), adds a Slot representing a New Line marker
; this slot also contains formatting information  - column start position
; 
; In: 
;     HL - pointer to puzzle data
;     IX - Slot pointer
; Out:
;     IX - Next slot
;
; Dirty: A, DE
;
;-----------------------------------------------------------------------------------
addNewLineSlot:
    ld (ix+slotStruct.id),0
    ld (ix+slotStruct.letter),CHAR_NEWLINE
    call justifySlots
    ld (ix+slotStruct.tileId),a
    ld de,slotStruct
    add ix,de

    ld a, (slotCount)
    inc a
    ld (slotCount),a

    ret





;-----------------------------------------------------------------------------------
;
; Function: removeAll()
;
; Sets slot  count to 0
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
removeAll:
    ;reset variables
    xor a
    ld (slotCount),a
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

    call Tile.rowColumnToPixel
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
    ld (Tile.letterRow),a

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
    ld a,(Tile.letterColumn)
    inc a
    ld (Tile.letterColumn),a

    ; point to the next slot
    add iy,de
    djnz .nextSlot
    jr .exit

.newLine:
    ;Column start position is stored in TileId
    ld a,(iy + slotStruct.tileId)
    ld (Tile.letterColumn),a
    ld a,(Tile.letterRow)
    inc a
    ld (Tile.letterRow),a
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
    push bc

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
    add LAYOUT_SLOT_CENTER_COLUMN
    
    pop bc
    ret



slotCount:
    db 0
slotList:
    block slotStruct * 64



    endmodule