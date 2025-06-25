    module Tile

SPRITE_PATTERN_OFFSET_A:    equ 8
ASCII_PATTERN_OFFSET:       equ 'A' - SPRITE_PATTERN_OFFSET_A

LAYOUT_TILE_START_ROW:      equ 7

DRAG_BOUNDS_X_MIN:               equ 16
DRAG_BOUNDS_X_MAX:               equ 319 - 16
DRAG_BOUNDS_X_MAX_LSB:           equ DRAG_BOUNDS_X_MAX - 256
DRAG_BOUNDS_X_MAX_IN_BOUNDS:     equ DRAG_BOUNDS_X_MAX - 1
DRAG_BOUNDS_X_MAX_LSB_IN_BOUNDS: equ DRAG_BOUNDS_X_MAX_IN_BOUNDS - 256
DRAG_BOUNDS_Y_MIN:               equ 16
DRAG_BOUNDS_Y_MAX:               equ 255 - 16
DRAG_BOUNDS_Y_MAX_IN_BOUNDS:     equ DRAG_BOUNDS_Y_MAX - 1


;-----------------------------------------------------------------------------------
; 
; struct: tileStruct
; 
; 
; 
;-----------------------------------------------------------------------------------
    struct @tileStruct
id          byte
letter      byte
    ends


;-----------------------------------------------------------------------------------
;
; Function: createTiles(uint8 id, uint16 ptr) -> uint8 nextId
; 
; Sets up the tile lists from the puzzle data
; 
; In: 
;     C - gameId of the first item
;     HL - pointer to puzzle data
;
; Out C - gameId advanced ready for next game item
;
; Dirty: A, BC, HL, DE, IX
;
;-----------------------------------------------------------------------------------
createTiles:
    ld ix, tileList

    ; loop starts off by inc hl, so cancel it out here
    dec hl
.nextLetter:
    inc hl
    ld a,(hl)

    cp CHAR_SPACE
    jr z,.nextLetter

    cp CHAR_NEWLINE
    jr z,.nextLetter

    or a
    jr z,.exit

    ;new tile
    ld (ix+tileStruct.id),c
    ld (ix+tileStruct.letter),a
    ld de,tileStruct
    add ix,de
    ;advance gameId
    inc c

    ld a, (tileCount)
    inc a
    ld (tileCount),a

    ;next letter
    jr .nextLetter

.exit:
    ret



;-----------------------------------------------------------------------------------
;
; Function: removeAll()
;
; Sets tile count to 0
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
removeAll:
    ;reset variables
    xor a
    ld (tileCount),a
    ret


;-----------------------------------------------------------------------------------
;
; Function: tileToSprite(uint16 ptrSprite, uint16 ptrTile)
;
; Convert tileStruct to a spriteItem
;
; In: IX - pointer to spriteItem struct
;     IY - pointer to tileStruct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
tileToSprite:
    ;Use tile ID as game ID
    ld a,(iy + tileStruct.id)
    ld (ix + spriteItem.gameId),a

    ; convert the letter to its sprite pattern
    ld a,(iy + tileStruct.letter)
    sub ASCII_PATTERN_OFFSET
    ld (ix + spriteItem.pattern),a
      
    call Tile.rowColumnToPixel
    ret


;-----------------------------------------------------------------------------------
;
; Function: tilesToSprites()
;
; Add all the items in the tile list to the sprite list
;
; Dirty A, IX, IY
;
;-----------------------------------------------------------------------------------
tilesToSprites:
    push bc
    push de

    ;init vars for layout
    ;What are the start/end columns
    ld a,(tileCount)
    call Grid.getColumnBounds
    ld (endCol),bc
    
    ld a,b
    ld (Tile.column),a

    ld a, LAYOUT_TILE_START_ROW
    ld (Tile.row),a

    ld a, (tileCount)
    ld b, a
    ld iy, tileList
    ld de,tileStruct
.nextTile:
    ; Create a spriteItem, returns IX ptr to spriteItem 
    call SpriteList.reserveSprite
    ; Takes IX, IY
    call tileToSprite
    call tilesLayout
    ; point to the next tile
    add iy,de

    djnz .nextTile

    pop de
    pop bc
    ret





;-----------------------------------------------------------------------------------
;
; Function tilesLayout()
; helper function to layout the tiles
; 
; Dirty A
; 
;-----------------------------------------------------------------------------------
tilesLayout:
    push bc
    ld a,(endCol)
    ld b,a
    ld a,(Tile.column)
    cp b
    jr nz, .noColumnOverflow

    ; Maximum number of tiles in this row
    ; So move to next row and start column

    ; Increase row
    ld a,(Tile.row)
    inc a
    ld (Tile.row),a

    ld a,(startCol)
    dec a
.noColumnOverflow:
    inc a
    ld (Tile.column),a
    pop bc
    ret



;-----------------------------------------------------------------------------------
;
; Function: boundsCheck
;
; Checks if the tile is in bounds, if not the tile X,Y is corrected to be back within 
; bounds. The Zero flag is set if the tile was out of bounds.
;
; In:   IX - pointer to spriteItem of the tile
; Out:  Z flag - Set out of bounds, not set in bounds
;
;-----------------------------------------------------------------------------------
boundsCheck:
    ; Test if x is negative
    ld a,(ix+spriteItem.x+1)
    bit 7,a
    jr nz, .outOfBoundsLowX

    ;If high byte is 1, then only check for max X
    cp 1
    jr z, .xMax

    ;Test x min
    ld a,(ix+spriteItem.x)
    cp DRAG_BOUNDS_X_MIN
    jr c, .outOfBoundsLowX
    jr .yMin
    
.xMax:
    ;Test x max
    ld a,(ix+spriteItem.x)
    cp DRAG_BOUNDS_X_MAX_LSB
    jr nc, .outOfBoundsHighX

.yMin:
    ;Test y min
    ld a,(ix+spriteItem.y)
    cp DRAG_BOUNDS_Y_MIN
    jr c, .outOfBoundsLowY

    ;Test y max
    cp DRAG_BOUNDS_Y_MAX
    jr nc, .outOfBoundsHighY

    ; clear sign flag
    or 1
    ret

.outOfBoundsLowX:
    ld (ix+spriteItem.x),DRAG_BOUNDS_X_MIN
    ld (ix+spriteItem.x+1),0
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsHighX:
    ld (ix+spriteItem.x),DRAG_BOUNDS_X_MAX_LSB_IN_BOUNDS
    ld (ix+spriteItem.x+1),1
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsLowY:
    ld (ix+spriteItem.y),DRAG_BOUNDS_Y_MIN
    ; Set sign flag to indicate out of bounds
    xor a
    ret

.outOfBoundsHighY:
    ld (ix+spriteItem.y),DRAG_BOUNDS_Y_MAX_IN_BOUNDS
    ; Set sign flag to indicate out of bounds
    xor a
    ret


;-----------------------------------------------------------------------------------
;
; Function: rowColumnToPixel(uint16 ptrSprite)
;
; Convert row and column variables to pixel co-ordinates and store then in the
; spriteItem struct.
;
; In: IX - pointer to spriteItem struct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
rowColumnToPixel:
    push bc

    ld a,(row)
    call Grid.rowToPixel
    ld (ix + spriteItem.y),a

    ld a,(column)
    call Grid.colToPixel
    ld (ix + spriteItem.x),c
    ld (ix + spriteItem.x + 1),b
 
    pop bc
    ret



row:
    db 0
column:
    db 0
endCol:
    db 0
startCol:
    db 0

tileCount:
    db 0
tileList:
    block tileStruct * 64


    endmodule