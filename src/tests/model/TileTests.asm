    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Tile

UT_createTiles1:
    call Tile.removeAll
    call GameId.reset
    ld hl,.data
    call Tile.createTiles
    TEST_MEMORY_BYTE Tile.tileCount,13

    ;Check tileList[1] C
    TEST_MEMORY_BYTE Tile.tileList+tileStruct+tileStruct.letter,'C'

    TC_END
.data:
    db "ACORN\nELECTRON",0


UT_findByLetter1:
    call Tile.removeAll
    call GameId.reset
    ld hl,.data
    call Tile.createTiles

    ld a,'N'
    call Tile.findByLetter
    nop ; ASSERTION HL == Tile.tileList + 4 * tileStruct

    ld a,'X'
    call Tile.findByLetter
    nop ; ASSERTION HL == 0

    TC_END
.data:
    db "ACORN\nELECTRON",0


UT_pickRandomTile1:
    call Tile.removeAll
    call GameId.reset
    ld hl,.data
    call Tile.createTiles

    ld b,0
.loop:
    call Tile.pickRandomTile
    nop ; ASSERTION HL >= Tile.tileList
    nop ; ASSERTION HL <= Tile.tileList + 12 * tileStruct
    djnz .loop

    TC_END
.data:
    db "ACORN\nELECTRON",0



UT_tileToSprite1:
    ld a,10
    ld (Tile.row),a
    ld a,15
    ld (Tile.column),a
    ld iy, .tileData
    ld ix, .spriteData
    call Tile.tileToSprite
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData + spriteItem.pattern,'J' - Tile.ASCII_PATTERN_OFFSET
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData + spriteItem.gameId, 42
    TC_END
.tileData:
    ; id, letter
    tileStruct 42, 'J'
.spriteData:
    ; id, x, y, palette, pattern, gameId, flags 
    spriteItem 0, 0, 0, 0, 0, 0, 0

UT_tilesToSprites1:
    call SpriteList.removeAll
    call Tile.removeAll
    call Tile.removeAll
    ld hl,.data
    call Tile.createTiles
    call Tile.tilesToSprites

    TEST_MEMORY_BYTE SpriteList.count,17

    ;Test the P in CHIP (11th letter)
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 10 + spriteItem.pattern,'P' - Tile.ASCII_PATTERN_OFFSET

    TC_END
.data:
    db "FISH AND\nCHIP FRIDAY",0


UT_tilesLayout1:
    WRITE_BYTE Tile.startCol,8
    WRITE_BYTE Tile.endCol,12
    WRITE_BYTE Tile.row,10
    WRITE_BYTE Tile.column,8
    call Tile.tilesLayout
    TEST_MEMORY_BYTE Tile.row,10
    TEST_MEMORY_BYTE Tile.column,9
    TC_END

UT_tilesLayout2:
    WRITE_BYTE Tile.startCol,8
    WRITE_BYTE Tile.endCol,12
    WRITE_BYTE Tile.row,10
    WRITE_BYTE Tile.column,12
    call Tile.tilesLayout
    TEST_MEMORY_BYTE Tile.row,11
    TEST_MEMORY_BYTE Tile.column,8
    TC_END


; In bounds
UT_boundsCheck1:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 32, y = 48 - inbounds
    spriteItem 42,32,48,0,0,0,0

; Out of bounds
; x = 8, y = 48 - x out of bounds
UT_boundsCheck2:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_Z
    TEST_MEMORY_WORD .data + spriteItem.x, Tile.DRAG_BOUNDS_X_MIN
    TEST_MEMORY_WORD .data + spriteItem.y, 48
    TC_END
.data:
    spriteItem 42,8,48,0,0,0,0

; Out of bounds
; x = -2, y = 48 - x out of bounds
UT_boundsCheck3:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_Z
    TEST_MEMORY_WORD .data + spriteItem.x, Tile.DRAG_BOUNDS_X_MIN
    TEST_MEMORY_WORD .data + spriteItem.y, 48
    TC_END
.data:
    spriteItem 42,0xfffe,48,0,0,0,0

; Out of bounds
; x = 310, y = 48 - x out of bounds
UT_boundsCheck4:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_Z
    TEST_MEMORY_WORD .data + spriteItem.x, Tile.DRAG_BOUNDS_X_MAX_IN_BOUNDS
    TEST_MEMORY_WORD .data + spriteItem.y, 48
    TC_END
.data:
    spriteItem 42,310,48,0,0,0,0

; Out of bounds
; x = 48, y = 7 -  y out of bounds
UT_boundsCheck5:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_Z
    TEST_MEMORY_WORD .data + spriteItem.x, 48
    TEST_MEMORY_WORD .data + spriteItem.y, Tile.DRAG_BOUNDS_Y_MIN
    TC_END
.data:
    spriteItem 42,48,7,0,0,0,0

; Out of bounds
; x = 48, y = 250 -  y out of bounds
UT_boundsCheck6:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_Z
    TEST_MEMORY_WORD .data + spriteItem.x, 48
    TEST_MEMORY_WORD .data + spriteItem.y, Tile.DRAG_BOUNDS_Y_MAX_IN_BOUNDS
    TC_END
.data:
    spriteItem 42,48,250,0,0,0,0

; In bounds, x = 300, y = 200
UT_boundsCheck7:
    ld ix, .data
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 32, y = 48 - inbounds
    spriteItem 49,300,200,0,0,0,0

; Regression test, check tiles are not stuck
; boundsCheck should move tile in bounds, 
; so a second call should be in-bounds
; X < MIN
UT_stuckTest1:
    ld ix, .data
    call Tile.boundsCheck
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 1, y = 100 - out of bounds
    spriteItem 49,1,100,0,0,0,0

; Regression test, check tiles are not stuck
; boundsCheck should move tile in bounds, 
; so a second call should be in-bounds
; X > MAX
UT_stuckTest2:
    ld ix, .data
    call Tile.boundsCheck
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 330, y = 100 - out of bounds
    spriteItem 49,330,100,0,0,0,0

; Regression test, check tiles are not stuck
; boundsCheck should move tile in bounds, 
; so a second call should be in-bounds
; Y < MIN
UT_stuckTest3:
    ld ix, .data
    call Tile.boundsCheck
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 100, y = 1 - out of bounds
    spriteItem 49,100,1,0,0,0,0

; Regression test, check tiles are not stuck
; boundsCheck should move tile in bounds, 
; so a second call should be in-bounds
; Y > MAX
UT_stuckTest4:
    ld ix, .data
    call Tile.boundsCheck
    call Tile.boundsCheck
    TEST_FLAG_NZ
    TC_END
.data:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    ; x = 100, y = 1 - out of bounds
    spriteItem 49,100,255,0,0,0,0



wordAcorn:
    db "ACORN",0

spriteItemBuffer:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    spriteItem 0,0,0,0,0,0,0

    endmodule
