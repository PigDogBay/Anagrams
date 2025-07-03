;-----------------------------------------------------------------------------------
; 
; Module GameId
; Keeps track of the game ids for tiles, slots and buttons
; 
;-----------------------------------------------------------------------------------

    module GameId



SLOT_ID:                  equ %10000000
TILE_ID:                  equ %01000000
BUTTON_ID:                equ %00000000


slotId:
    db 0
tileId:
    db 0
buttonId:
    db 0


;-----------------------------------------------------------------------------------
; 
; Function: reset()
; 
; Resets slot, tile and button IDs
; Dirty A
;
;-----------------------------------------------------------------------------------
reset:
    ld a, SLOT_ID
    ld (slotId), a
    ld a, TILE_ID
    ld (tileId), a
    ld a, BUTTON_ID
    ld (buttonId), a
    ret


;-----------------------------------------------------------------------------------
; 
; Function: nextSlotId() -> uint8
;
; Returns a new slot ID
; Out: A = new slot ID
; Dirty A
;-----------------------------------------------------------------------------------
nextSlotId:
    ld a,(slotId)
    inc a
    ld (slotId),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextTileId() -> uint8
;
; Returns a new tile ID
; Out: A = new tile ID
; Dirty A
;-----------------------------------------------------------------------------------
nextTileId:
    ld a,(tileId)
    inc a
    ld (tileId),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextButtonId() -> uint8
;
; Returns a new button ID
; Out: A = new button ID
; Dirty A
;-----------------------------------------------------------------------------------
nextButtonId:
    ld a,(buttonId)
    inc a
    ld (buttonId),a
    ret

    endmodule