    module Print

ASCII_TO_TILE_INDEX      equ 32
CHARACTERS_PER_LINE      equ 40

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


;-----------------------------------------------------------------------------------
; 
; Function: printCentred(uint16 str, uint8 y, uint8 attr) 
; Sets the x position so that the
; 
; In: HL - pointer to null terminated string
;     B - attribute value, bits:
;         7-4: Palette Offset
;           3: X Mirror
;           2: Y Mirror
;           1: Rotate (90 clockwise)
;           0: * 1 = ULA over tilemap, 0 = tilemap over ULA
;     E - Y position 
; 
; Out: D - X position of the string
;
;-----------------------------------------------------------------------------------
printCentred:
    call String.len
    neg
    add CHARACTERS_PER_LINE
    sra a
    ld d,a
    call setCursorPosition
    jp printString


;-----------------------------------------------------------------------------------
; 
; Function: bufferPrint(uint16 buffer, uint16 str) -> uint16
; 
; Copies the string into the buffer, null terminator is also copied
;
; In: DE - Pointer to the buffer
;     HL - pointer to null terminated string
;
; Out: DE - Pointer to next char (null terminator) in the buffer
; 
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
bufferPrint:
    call String.len
    ld b,0
    ld c,a
    ldir
    ; Null terminate working string
    ex de,hl
    ld (hl),0
    ex de,hl
    ret

;-----------------------------------------------------------------------------------
; 
; Function: clearLine(uint8 y) 
; 
; Fills the line with spaces
; 
; In: E - Y position 
; 
; Dirty None
;
;-----------------------------------------------------------------------------------
clearLine:
    ld d,0
    call setCursorPosition
    ;Add start address
    ld hl, (tilemapAddress)
    ld (hl),0
    ld de,hl
    inc de
    ld bc,80 - 1
    ldir
    ret    

;-----------------------------------------------------------------------------------
;
; Variables 
;
;-----------------------------------------------------------------------------------

tilemapAddress:
    dw Tilemap.START_OF_TILEMAP

buffer: 
    block CHARACTERS_PER_LINE+1


    endmodule