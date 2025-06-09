    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Tile

UT_letterToSprite1:
    ld a,10
    ld (Tile.letterRow),a
    ld a,15
    ld (Tile.letterColumn),a
    ld ix, spriteItemBuffer
    ld a, 'S'
    call Tile.letterToSprite
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.pattern,'S' - 57
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.x,16
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.x+1,1
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.y,192
    TC_END

UT_nextColumn1:
    ld a,10
    ld (Tile.letterRow),a
    ld a,8
    ld (Tile.letterColumn),a
    call Tile.nextColumn
    TEST_MEMORY_BYTE Tile.letterRow,10
    TEST_MEMORY_BYTE Tile.letterColumn,9
    TC_END

UT_nextColumn2:
    ld a,10
    ld (Tile.letterRow),a
    ld a,Tile.MAX_COLUMN
    ld (Tile.letterColumn),a
    call Tile.nextColumn
    TEST_MEMORY_BYTE Tile.letterRow,11
    TEST_MEMORY_BYTE Tile.letterColumn,0
    TC_END

UT_wordToSprites1:
    call SpriteList.removeAll
    ld a,5
    ld (Tile.letterRow),a
    ld a,7
    ld (Tile.letterColumn),a
    ld hl,wordAcorn
    call Tile.wordToSprites
    TEST_MEMORY_BYTE SpriteList.count,5
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern,'A' - 57
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.id,0
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.x,7*16+32
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.x+1,0
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.y,5*16+32

    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 4 + spriteItem.pattern,'N' - 57
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 4 + spriteItem.id,4
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 4 + spriteItem.x,208
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 4 + spriteItem.x+1,0
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 4 + spriteItem.y,112

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
    TEST_MEMORY_WORD .data + spriteItem.x, Tile.DRAG_BOUNDS_X_MAX
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
    TEST_MEMORY_WORD .data + spriteItem.y, Tile.DRAG_BOUNDS_Y_MAX
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





wordAcorn:
    db "ACORN",0

spriteItemBuffer:
    ; id, x (2-bytes), y, palette, pattern, gameId, flags
    spriteItem 0,0,0,0,0,0,0

    endmodule
