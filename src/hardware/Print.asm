    module Print

ASCII_TO_TILE_INDEX      equ 32


;-----------------------------------------------------------------------------------
; 
; Function: printString(uint16 str) 
; 
; Prints a string starting at the current position, 
; moves the cursor along to position after last printed char
;
; In: HL - pointer to null terminated string
; 
; Dirty None
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
    ; Add x position
    ld a,d
    add hl, a

    ;Add start address
    add hl, Tilemap.START_OF_TILEMAP
    ld (tilemapAddress),hl
    pop hl, af
    ret

tilemapAddress:
    dw Tilemap.START_OF_TILEMAP

    endmodule