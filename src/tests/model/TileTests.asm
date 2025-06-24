    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Tile

UT_createTiles1:
    call Tile.removeAll
    ld c,42
    ld hl,.data
    call Tile.createTiles
    ; gameId will be increased by number of slots + tiles created
    nop ; ASSERTION c == 42 + (5 + 8)
    TEST_MEMORY_BYTE Tile.tileCount,13

    ;Check tileList[1] C
    TEST_MEMORY_BYTE Tile.tileList+tileStruct+tileStruct.id,43
    TEST_MEMORY_BYTE Tile.tileList+tileStruct+tileStruct.letter,'C'

    TC_END
.data:
    db "ACORN\nELECTRON."




UT_tileToSprite1:
    ld a,10
    ld (Tile.letterRow),a
    ld a,15
    ld (Tile.letterColumn),a
    ld iy, .tileData
    ld ix, .spriteData
    call Tile.tileToSprite
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData + spriteItem.pattern,'J' - Tile.ASCII_PATTERN_OFFSET
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData + spriteItem.gameId, 42
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData+spriteItem.x,16
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData+spriteItem.x+1,1
    TEST_MEMORY_BYTE UT_tileToSprite1.spriteData+spriteItem.y,192
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
    ld c,100
    ld hl,.data
    call Tile.createTiles
    call Tile.tilesToSprites

    TEST_MEMORY_BYTE SpriteList.count,17

    ;Test the P in CHIP (11th letter)
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 10 + spriteItem.pattern,'P' - Tile.ASCII_PATTERN_OFFSET
    ; Slots also get assigned gameId, so *2
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 10 + spriteItem.gameId,100 + 10*2

    TC_END
.data:
    db "FISH AND\nCHIP FRIDAY."


UT_tilesLayout1:
    ld a,10
    ld (Tile.letterRow),a
    ld a,8
    ld (Tile.letterColumn),a
    call Tile.tilesLayout
    TEST_MEMORY_BYTE Tile.letterRow,10
    TEST_MEMORY_BYTE Tile.letterColumn,9
    TC_END

UT_tilesLayout2:
    ld a,10
    ld (Tile.letterRow),a
    ld a,42
    ld (Tile.letterColumn),a
    call Tile.tilesLayout
    TEST_MEMORY_BYTE Tile.letterRow,11
    TEST_MEMORY_BYTE Tile.letterColumn,0
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
