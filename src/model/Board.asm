    
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
    ;TODO jump to NPE trap
    ret z
    
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


    endmodule
