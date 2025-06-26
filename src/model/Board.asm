    
;-----------------------------------------------------------------------------------
; 
; This module handles the interaction between slots and tiles
;
;-----------------------------------------------------------------------------------

    module Board
    
TILE_SLOT_OVERLAP:              equ 12

;-----------------------------------------------------------------------------------
;
; Function: isTileOverSlot(uint16 ptrTile) -> uint16
;
; Searches through the sprites to find if the tile is over a slot sprite
;
;
; Out: 
;       A - 0 = not over slot, 1 = over slot 
;       IY - matching slot sprite
;
; Dirty: A,B,DE,IX,IY
;
;-----------------------------------------------------------------------------------
isTileOverSlot:
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




    endmodule
