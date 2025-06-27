    
;-----------------------------------------------------------------------------------
; 
; This module handles the interaction between slots and tiles
;
;-----------------------------------------------------------------------------------

    module Board

TILE_SLOT_OVERLAP:              equ 12
BOUNCE_PIXELS_OFFSET:           equ 8

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
    ld a, TILE_SLOT_OVERLAP
    call SpriteList.collisionCheck
    or a
    jr nz, .collisionDetected
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





    endmodule
