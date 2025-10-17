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
; Function: setCursorPosition(uint8 x : d, uint8 y : e) 
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
; Function: bufferPrint(uint16 buffer, uint16 value) -> uint16
; 
; Copies the string into the buffer, null terminator is also copied
;
; In: DE - Pointer to the buffer
;     HL - value to print
;
; Out: DE - Pointer to next char (null terminator) in the buffer
; 
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
bufferPrintNumber:
    ld a,1
    call ScoresConvert.ConvertToDecimal
    ;point to the end of the string
    ex de,hl
    add hl,a
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
; Function: horizontalLine(uint8 x1 : d, uint8 y1 : e, uint8 x2 : h, uint8 tile : c, uint8 attr : b) 
; 
; In: D - X1 position
;     E - Y position 
;     H - X2 Position
;     C - Tile to print
;     B - attribute value, bits:
;         7-4: Palette Offset
;           3: X Mirror
;           2: Y Mirror
;           1: Rotate (90 clockwise)
;           0: * 1 = ULA over tilemap, 0 = tilemap over ULA
; 
; Dirty A, HL
;
;-----------------------------------------------------------------------------------
horizontalLine:
    push bc,de,hl

    ;Line length - 1 = x2 - x1
    ld a,h
    sub d

    ; Function: setCursorPosition(uint8 x : d, uint8 y : e) 
    call setCursorPosition
    ld hl,(tilemapAddress)
    ld (hl),c
    inc hl
    ld (hl),b
    ld de,hl
    inc de
    dec hl

    ;Set up counter, a = length - 1
    ; Check if length = 1 (a = 0)
    or a
    jr z, .done
    ;Double A as each tile is 2 bytes
    sla a
    ld b,0
    ld c,a
    ldir
.done:
    pop hl,de,bc
    ret

;-----------------------------------------------------------------------------------
; 
; Function: verticalLine(uint8 x : D, uint8 y1 : E, uint8 y2 : H, uint8 tile : C, uint8 attr : B) 
; 
; In: D - X position
;     E - Y1 position 
;     H - Y2 Position
;     C - Tile to print
;     B - attribute value, bits:
;         7-4: Palette Offset
;           3: X Mirror
;           2: Y Mirror
;           1: Rotate (90 clockwise)
;           0: * 1 = ULA over tilemap, 0 = tilemap over ULA
; 
; Dirty A, HL
;
;-----------------------------------------------------------------------------------
verticalLine:
    push bc,de,hl
    ;Line length - 1 = y2 - y1
    ld a,h
    sub e
    inc a

    ; Function: setCursorPosition(uint8 x : d, uint8 y : e) 
    call setCursorPosition
    ld hl,(tilemapAddress)
.loop:
    ld (hl),c
    inc hl
    ld (hl),b
    ;next position down
    add hl, CHARACTERS_PER_LINE * 2 - 1
    dec a
    jr nz, .loop

    pop hl,de,bc
    ret

;-----------------------------------------------------------------------------------
; 
; Function: rectangle(uint16 *rectStruct) 
; 
; In: IX - pointer to rectStruct
;     C - Tile to print
;     B - attribute value, bits:
;         7-4: Palette Offset
;           3: X Mirror
;           2: Y Mirror
;           1: Rotate (90 clockwise)
;           0: * 1 = ULA over tilemap, 0 = tilemap over ULA
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
rectangle:
    push bc,de,hl

    ;Top DE = x1,y1 ; H = x2
    ld d,(ix+rectStruct.x1)
    ld e,(ix+rectStruct.y1)
    ld h,(ix+rectStruct.x2)
    call horizontalLine

    ;Bottom DE = x1,y2 ; H = x2
    ld d,(ix+rectStruct.x1)
    ld e,(ix+rectStruct.y2)
    ld h,(ix+rectStruct.x2)
    call horizontalLine

    ;Left DE = x1,y1 ; H = y2
    ld d,(ix+rectStruct.x1)
    ld e,(ix+rectStruct.y1)
    ld h,(ix+rectStruct.y2)
    call verticalLine

    ;Right DE = x2,y1 ; H = y2
    ld d,(ix+rectStruct.x2)
    ld e,(ix+rectStruct.y1)
    ld h,(ix+rectStruct.y2)
    call verticalLine

    pop hl,de,bc
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