    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_SpriteList

UT_addSprite1:
    call SpriteList.removeAll
    ld hl, dataAddSprite1
    ;Add the sprite 3 times
    call SpriteList.addSprite
    call SpriteList.addSprite
    call SpriteList.addSprite
    nop ; ASSERTION HL == TestSuite_SpriteList.dataAddSprite1 
    TEST_MEMORY_BYTE SpriteList.count, 3
    TEST_MEMORY_BYTE SpriteList.nextSpriteId, 3
    TEST_MEMORY_WORD SpriteList.nextEntryPtr, SpriteList.list + 3 * spriteItem
    TC_END
dataAddSprite1:
    ;id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 200, 100, 0, 5, 42, %00001000


UT_reserveSprite1:
    call SpriteList.removeAll

    call SpriteList.reserveSprite
    nop ; ASSERTION IX == SpriteList.list
    TEST_MEMORY_BYTE IX, 0
    TEST_MEMORY_BYTE SpriteList.count, 1

    call SpriteList.reserveSprite
    nop ; ASSERTION IX == SpriteList.list + spriteItem
    TEST_MEMORY_BYTE IX, 1
    TEST_MEMORY_BYTE SpriteList.count, 2

    TC_END

;Mid list
UT_find1:
    COPY_DATA findLen, findData
    ld a,3
    call SpriteList.find
    ld de, SpriteList.list + spriteItem * 3
    nop ; ASSERTION HL == DE
    TC_END

;Start
UT_find2:
    COPY_DATA findLen, findData
    ld a,0
    call SpriteList.find
    ld de, SpriteList.list
    nop ; ASSERTION HL == DE
    TC_END

;End
UT_find3:
    COPY_DATA findLen, findData
    ld a,4
    call SpriteList.find
    ld de, SpriteList.list + spriteItem*4
    nop ; ASSERTION HL == DE
    TC_END
;Not found
UT_find4:
    COPY_DATA findLen, findData
    ld a,99
    call SpriteList.find
    nop ; ASSERTION HL == 0
    TC_END

findData:
    db 5
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0,0,0
    spriteItem 1,100,150,0,16,0,0
    spriteItem 2,20,10,0,8,0,0
    spriteItem 3,60,20,0,30,0,0
    spriteItem 4,100,30,0,24,0,0
findLen: equ $ - findData



    endmodule