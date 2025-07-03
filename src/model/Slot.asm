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
;   Macro to return pointer to the slot at the specified index (0 based)
;
;   Dirty: indexRegister
;
;-----------------------------------------------------------------------------------
    macro SLOT_AT indexRegister, index
        ld indexRegister, Slot.slotList + slotStruct * index
    endm

;-----------------------------------------------------------------------------------
; 
;   Macro to get the slot ID at the specified index (0 based)
;
;   Out: A = ID
;
;-----------------------------------------------------------------------------------
    macro SLOT_ID_AT index
        ld a, (Slot.slotList + slotStruct * index)
    endm


;-----------------------------------------------------------------------------------
;
; Function: find(uint8 gameId) -> uint16
;
; Finds the slotStruct with matching gameId
;
; In:    A - id
; Out:   HL - ptr to slot's struct, null if not found
;
; Dirty: B,HL
;
;-----------------------------------------------------------------------------------
find:
    ld hl,slotCount
    ld b,(hl)
    ; point to list
    inc hl
.next
    cp (hl)
    ret z
    add hl,slotStruct
    djnz .next
    ; no match found
    ld hl,0
    ret



;-----------------------------------------------------------------------------------
;
; Function: createSlots(uint8 id, uint16 ptr) -> uint8 nextId
; 
; Sets up the slot lists from the puzzle data
; 
; In: 
;     HL - pointer to puzzle data
;
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
    ld (ix+slotStruct.letter),a
    ld (ix+slotStruct.tileId),0
    call GameId.nextSlotId
    ld (ix+slotStruct.id),a
    add ix,de

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
    ld (ix + spriteItem.flags),MouseDriver.MASK_HOVERABLE | Board.MASK_IS_SLOT
    call rowColumnToPixel
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
    ld (row),a

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
    ld a,(column)
    inc a
    ld (column),a

    ; point to the next slot
    add iy,de
    djnz .nextSlot
    jr .exit

.newLine:
    ;Column start position is stored in TileId
    ld a,(iy + slotStruct.tileId)
    ld (column),a
    ld a,(row)
    inc a
    ld (row),a
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

;-----------------------------------------------------------------------------------
;
; Function: rowColumnToPixel(uint16 ptrSprite)
;
; Convert row and column variables to pixel co-ordinates and store then in the
; spriteItem struct.
;
; In: IX - pointer to spriteItem struct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
rowColumnToPixel:
    push bc

    ld a,(row)
    call Grid.rowToPixel
    ld (ix + spriteItem.y),a

    ld a,(column)
    call Grid.colToPixel
    ld (ix + spriteItem.x),c
    ld (ix + spriteItem.x + 1),b
 
    pop bc
    ret

;-----------------------------------------------------------------------------------
;
; Function: slotTile(uint8 slotId, uint8 tileId)
;
; Will search the list of slots to find with matching slotId,
; this slots .tileId field will be set to tileId, replacing the 
; previous value.
;
; Throws SlotNotFound exception if no matching slot found
;
; In: A - slot ID to find
;     C - tile ID to slot
;
; Dirty A,B,HL
;
;-----------------------------------------------------------------------------------
slotTile:
    call find
    ;check if HL is not 0
    ld a,h
    or l
    call z, Exceptions.slotNotFound
    ld a, slotStruct.tileId
    add hl,a
    ld (hl),c
    ret

;-----------------------------------------------------------------------------------
;
; Function: unslotTile(uint8 tileId)
;
; Will search the list of slots to find a slot that has the matching tileId slotted,
; this slots .tileId will be set to 0.
;
; In: A - tile ID to unslot
; 
; Dirty A,BC,DE,IX
;
;-----------------------------------------------------------------------------------
unslotTile:
    ld c,a
    ld a, (slotCount)
    ld b,a
    ld ix,slotList
    ld de, slotStruct
.next:
    ld a,(ix+slotStruct.tileId)
    cp c
    jr z, .unslot
    add ix,de
    djnz .next
    ret
.unslot:
    ld (ix+slotStruct.tileId),0
    ret


row:
    db 0
column:
    db 0

slotCount:
    db 0
slotList:
    block slotStruct * 64



    endmodule