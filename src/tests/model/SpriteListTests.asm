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


; Test spriteItem data is swapped except for spriteId
; Also check HL now points to index[1] of the list
UT_bringToFront1:
    ; Set up
    call SpriteList.removeAll
    ; Mouse sprite
    ld hl, bringToFrontData
    call SpriteList.addSprite
    ; Sprite gameID = 42
    ld hl, bringToFrontData + spriteItem
    call SpriteList.addSprite
    ; Sprite gameID = 75
    ld hl, bringToFrontData + spriteItem * 2
    call SpriteList.addSprite

    ld ix, SpriteList.list + spriteItem * 2
    call SpriteList.bringToFront

    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.id,1
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.gameId,75
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 2 + spriteItem.id,2
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 2 + spriteItem.gameId,42

    ; Check HL points to index[1] of the list
    nop     ;ASSERTION ix == SpriteList.list + spriteItem

    TC_END
; If HL points to first item check nothing is swapped
UT_bringToFront2:
    ; Set up
    call SpriteList.removeAll
    ; Mouse sprite
    ld hl, bringToFrontData
    call SpriteList.addSprite
    ; Sprite gameID = 42
    ld hl, bringToFrontData + spriteItem
    call SpriteList.addSprite
    ; Sprite gameID = 75
    ld hl, bringToFrontData + spriteItem * 2
    call SpriteList.addSprite

    ; Point to index[1]
    ld ix, SpriteList.list + spriteItem * 1
    call SpriteList.bringToFront

    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.id,1
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.gameId,42
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 2 + spriteItem.id,2
    TEST_MEMORY_BYTE SpriteList.list + spriteItem * 2 + spriteItem.gameId,75

    ; Check HL points to index[1] of the list
    nop     ;ASSERTION ix == SpriteList.list + spriteItem

    TC_END
bringToFrontData:
    spriteItem 0,160,128,0,0,0,0
    spriteItem 1,100,150,0,16,42,0
    spriteItem 2,20,10,0,8,75,0



;
; collisionCheck tests
;

    macro COLLISION_TEST x1,y1, x2,y2, overlap, expected
    ld hl, x1
    ld (.sprite1 + spriteItem.x),hl
    ld a, y1
    ld (.sprite1 + spriteItem.y),a
    
    ld hl, x2
    ld (.sprite2 + spriteItem.x),hl
    ld a, y2
    ld (.sprite2 + spriteItem.y),a

    ld ix,.sprite1
    ld iy,.sprite2
    ld a, overlap
    call SpriteList.collisionCheck
    ld b, expected
    nop ; ASSERTION A == b

    endm

UT_collisionCheck:
    COLLISION_TEST 0,0,0,0,5,1
    COLLISION_TEST 100,200,103,203,5,1
    COLLISION_TEST 103,203,100,200,5,1
    COLLISION_TEST 100,200,105,203,5,0
    COLLISION_TEST 100,200,103,205,5,0
    COLLISION_TEST 300,200,307,207,8,1
    TC_END
.sprite1:
    spriteItem 0,160,128,0,0,0,0
.sprite2:
    spriteItem 1,160,128,0,0,0,0

    endmodule