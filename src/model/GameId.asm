;-----------------------------------------------------------------------------------
; 
; Module GameId
; Keeps track of the game ids for tiles, slots and buttons
; 
;-----------------------------------------------------------------------------------

    module GameId

;Fixed ID's for buttons
@QUIT_BUTTON:           equ 1
@LIFELINE_1_BUTTON:     equ 2
@LIFELINE_2_BUTTON:     equ 3
@LIFELINE_3_BUTTON:     equ 4
@LIFELINE_4_BUTTON:     equ 5
END_OF_BUTTONS:         equ 10


SLOT_ID:                  equ %10000000
TILE_ID:                  equ %01000000
BUTTON_ID:                equ %00000000 + END_OF_BUTTONS
BUTTON_MASK:              equ %11000000

slotId:
    db 0
tileId:
    db 0
buttonId:
    db END_OF_BUTTONS

;-----------------------------------------------------------------------------------
; 
; Function: isSlot(uint8 slotId) -> Boolean
; 
; In: A slot ID
; Out: Z flag, NZ = is slot, Z = not a slot
;
;-----------------------------------------------------------------------------------
isSlot:
    push bc
    ld b,a
    and SLOT_ID
    ld a,b
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Function: isTile(uint8 slotId) -> Boolean
; 
; In: A tile ID
; Out: Z flag, NZ = is tile, Z = not a tile
;
;-----------------------------------------------------------------------------------
isTile:
    push bc
    ld b,a
    and TILE_ID
    ld a,b
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Function: isButton(uint8 buttonId) -> Boolean
; 
; In: A button ID
; Out: Z flag, NZ = is button, Z = not a button
;
;-----------------------------------------------------------------------------------
isButton:
    push bc
    ld b,a
    and BUTTON_MASK
    ld a,1
    jr z, .invertFlag:
    xor a
.invertFlag:
    or a
    ld a,b
    pop bc
    ret



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