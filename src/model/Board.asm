    
;-----------------------------------------------------------------------------------
; 
; This module handles the interaction between slots and tiles
;
;-----------------------------------------------------------------------------------

    module Board

TILE_SLOT_OVERLAP:              equ 12
BOUNCE_PIXELS_OFFSET:           equ 8

;Reserve flags 7-4 for use by the SpriteEngine
SPRITE_FLAGS_MASK:               equ %11110000


LIFELINE_OK:                                equ 0
LIFELINE_TILE_ALREADY_SLOTTED:              equ 1
LIFELINE_SLOT_NOT_FOUND:                    equ 2
LIFELINE_TILE_NOT_FOUND:                    equ 3

;-----------------------------------------------------------------------------------
;
; Function: isSelectedTileOverSlot() -> bool, uint16
;
; Searches through the sprites to find if the selected tile is over a slot sprite
; The selected tile, should be at index 1 in sprite list
;
; Out: 
;       A - 0 = not over slot, 1 = over slot 
;       IX - Tile sprite
;       IY - matching slot sprite
;
; Dirty: A,B,DE,IX,IY
;
;-----------------------------------------------------------------------------------
isSelectedTileOverSlot:
    ld a, (SpriteList.count)
    ;Discount mouse pointer and dragged tile sprites
    dec a
    dec a
    ld b,a
    ; Dragged tile has been brought to the front
    ; so is at index 1
    ld ix,SpriteList.list + spriteItem
    ;Start searching from index 2
    ld iy,SpriteList.list + spriteItem*2
    ld de, spriteItem
.next:
    ;Is sprite a slot?
    ld a,(iy+spriteItem.gameId)
    bit GameId.BIT_IS_SLOT,a
    jr z,.notASlot
    
    ld a, TILE_SLOT_OVERLAP
    call SpriteList.collisionCheck
    or a
    jr nz, .collisionDetected
.notASlot:
    add iy,de
    djnz .next

.collisionDetected:
    ret



;-----------------------------------------------------------------------------------
;
; Function: placeTile(uint16 tilePtr, uint16 slotPtr) -> bool
;
; Places the tile into the slot, returns 0 if the tile was placed successfully,
; or the gameId of the existing tile in the slot
;
; In:
;       IX - ptr to tile sprite
;       IY - ptr to slot sprite
;
; Out: 
;       A = 0 tile was slotted, gameId of existing tile (IX tile was not slotted)
;
; Dirty A
;
;-----------------------------------------------------------------------------------
placeTile:
    ;find slot
    ld a, (iy+spriteItem.gameId)
    call Slot.find
    ;check if HL is not 0
    ld a,h
    or l
    call z, Exceptions.nullPointer
    
    ;Get exisiting tileId
    ld a,slotStruct.tileId
    add hl,a
    ld a,(hl)
    or a
    ret nz

    ld a,(IX+tileStruct.id)
    ld (hl),a
    xor a
    ret

;-----------------------------------------------------------------------------------
;
; Function: bounceTile(uint16 ptr)
;
; Move the tile down and across 8px
;
; In:
;       IX - ptr to tile sprite
;
; Dirty: A, HL
;
;-----------------------------------------------------------------------------------
bounceTile:
    ld hl,(ix + spriteItem.x)
    add hl,BOUNCE_PIXELS_OFFSET
    ld (ix+spriteItem.x),hl

    ld a, (ix+spriteItem.y)
    add BOUNCE_PIXELS_OFFSET
    ld (ix+spriteItem.y),a
    ret





;-----------------------------------------------------------------------------------
;
; Function: snapTileToSlot(uint16 ptrTile, uint16 ptrSlot)
;
; Set the Tile's x-y coords Slot.x+1,Slot.y+1, so you can still see the slot underneath.
; Sets the slot's tileId to the game ID of the tile sprite
;
; In:
;       IX - ptr to tile sprite
;       IY - ptr to slot sprite
;
; Dirty: A, HL
;
;-----------------------------------------------------------------------------------
snapTileToSlot:
    ;Tile's x-y coords  = Slot.x+1,Slot.y+1
    ld hl,(iy+spriteItem.x)
    inc hl
    ld (ix+spriteItem.x),hl
    ld a, (iy+spriteItem.y)
    inc a
    ld (ix+spriteItem.y),a

    ;Find the matching slotStruct (result in HL)
    ld a,(iy+spriteItem.gameId)
    call Slot.find

    ;check if HL is not 0
    ld a,h
    or l
    call z, Exceptions.nullPointer

    ; Point HL to slotStruct.tileId field
    ld a, slotStruct.tileId
    add hl,a
    ;Get tile's gameId from the sprite
    ld a, (ix+spriteItem.gameId)
    ;slot.tileId = tileSpriteItem.gameId
    ld (hl),a

    ret


;-----------------------------------------------------------------------------------
;
; Function: isSolved() -> Bool
;
; Checks each slot to see if the slotted tile matches it letter
;
; Out: A 1 = Solved, 0 = not solved
; 
; Dirty A,B,DE,IY
;
;-----------------------------------------------------------------------------------
isSolved:
    ld a,(Slot.slotCount)
    ld b,a
    ld de, slotStruct
    ld iy, Slot.slotList
.loop:
    call isSlotSolved
    or a
    ret z
    add iy,de
    djnz .loop

    ;Solved, set A to 1 (TRUE)
    ld a,1
    ret

;-----------------------------------------------------------------------------------
;
; Function: isSlotSolved(uint16 ptr) -> Bool
;
; If the slotted tile matches the slot's letter
;
;  In: IY pointer to slotStruct
; Out: A 1 = Solved, 0 = not solved
; 
; Dirty A,HL
;
;-----------------------------------------------------------------------------------
isSlotSolved:
    ;Check for whitespace slot - whitespace is solved
    ld a,(iy+slotStruct.id)
    or a
    jr z, .solved

    ;Check has slotted tile
    ld a,(iy+slotStruct.tileId)
    or a
    jr z, .notSolved

    call Tile.find
    ;Throw exception if tile is not found
    ld a,h
    or l
    call z, Exceptions.tileNotFound
    ;get the letter from the tileStruct
    add hl, tileStruct.letter
    ld a,(hl)
    ;does it match the slots letter?
    cp (iy+slotStruct.letter)
    jr z, .solved

.notSolved:
    xor a
    ret
.solved:
    ld a,1
    ret




;-----------------------------------------------------------------------------------
;
; Function: findEmptyMatchingSlot(uint16 ptrTile) -> uint8, uint16
;
; Finds the first available slot that correctly matches the tile's letter
;
;  In: IX ptr to tile struct
; Out: A  0 = no matching slot
;      IY ptr to slot if A is not 0
; 
; Dirty A,DE, BC, IY
;
;-----------------------------------------------------------------------------------
findEmptyMatchingSlot:
    ld a,(Slot.slotCount)
    ld b,a
    ld de, slotStruct
    ld iy, Slot.slotList

    ;save tile letter in C
    ld a,(IX + tileStruct.letter)
    ld c,a

.loop:

    ;Skip whitespace slots
    ld a,(iy+slotStruct.id)
    or a
    jr z, .skip

    ;Skip occupied slots
    ld a,(iy+slotStruct.tileId)
    or a
    jr nz, .skip

    ;does letter match tile?
    ld a,c
    cp (iy + slotStruct.letter)
    ret z

.skip:
    add iy,de
    djnz .loop

    ; no matching empty slot found
    xor a    
    ret


;-----------------------------------------------------------------------------------
;
; Function: lifelineTile(uint16 ptrTile) -> uint16, uint8
;
; Reveals which slot belongs to the selected Tile
;
;  In: IX ptr to tile struct
; Out: A  0 = LIFELINE_ENUM result
;      IY ptr to slot if A is LIFELINE_OK
; 
; Dirty A,IY
;
;-----------------------------------------------------------------------------------
lifelineTile:
    push bc, de, hl
    ;Is tile already slotted?
    ld a,(ix+tileStruct.id)
    call Slot.findByTile
    ld a,h
    or l
    ld a, LIFELINE_TILE_ALREADY_SLOTTED
    jr nz, .exit

    ;Find first matching slot
    call findEmptyMatchingSlot
    or a
    ld a,LIFELINE_SLOT_NOT_FOUND
    jr z, .exit

    ld a, LIFELINE_OK

.exit:
    pop hl,de,bc
    ret


    endmodule
