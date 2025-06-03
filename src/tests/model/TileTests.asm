    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Tile

UT_letterToSprite1:
    ld a,42
    ld (Tile.nextSpriteId),a
    ld a,10
    ld (Tile.letterRow),a
    ld a,15
    ld (Tile.letterColumn),a
    ld ix, spriteItemBuffer
    ld a, 'S'
    call Tile.letterToSprite
    nop ; ASSERTION IX == TestSuite_Tile.spriteItemBuffer + spriteItem
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.pattern,'S' - 57
    TEST_MEMORY_BYTE spriteItemBuffer+spriteItem.id,42
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


spriteItemBuffer:
    ; id, x, y, pattern
    spriteItem 0,0,0,0

    endmodule
