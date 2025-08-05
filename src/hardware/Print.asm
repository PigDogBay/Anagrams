    module Print

ASCII_TO_TILE_INDEX      equ 32


;-----------------------------------------------------------------------------------
; 
; Function: printString(uint16 str, uint8 attr) 
; 
; Prints a string starting at the current position, 
; moves the cursor along to position after last printed char
;
; In: HL - pointer to null terminated string
;     B - attribute value, bits:
;         7-4: Palette Offset
;           3: X Mirror
;           2: Y Mirror
;           1: Rotate (90 clockwise)
;           0: * 1 = ULA over tilemap, 0 = tilemap over ULA
; 
; Dirty: None
;
;-----------------------------------------------------------------------------------
printString:
    push af, de, hl
    ld de, (tilemapAddress)
.next:
    ld a,(hl)
    or a
    jr z, .done
    sub ASCII_TO_TILE_INDEX
    ld (de),a
    inc de
    inc hl
    ;write attribute
    ld a,b
    ld (de),a
    inc de
    jr .next
.done:
    ld (tilemapAddress),de
    pop hl, de, af
    ret


;-----------------------------------------------------------------------------------
; 
; Function: setCursorPosition(uint8 x, uint8 y) 
; 
; In: D - X position
;     E - Y position 
; 
; Dirty None
;
;-----------------------------------------------------------------------------------
setCursorPosition:
    push af,hl
    ;multiply y position by 40 (number of columns)
    ld a,e
    ;multiply by 8
    sla a : sla a: sla a
    ld hl,0
    ;Add to hl 5x (8*5 = 40)
    add hl,a : add hl,a : add hl,a : add hl,a : add hl,a
    ; Add X position
    ld a,d
    add hl, a

    ;Multiply by 2 since 2 bytes per tile
    add hl,hl

    ;Add start address
    add hl, Tilemap.START_OF_TILEMAP
    ld (tilemapAddress),hl
    pop hl, af
    ret

tilemapAddress:
    dw Tilemap.START_OF_TILEMAP

    endmodule