    module TestSuite_Appear

UT_removeAll1:
    call Appear.removeAll
    TEST_MEMORY_BYTE Appear.count,0
    TEST_MEMORY_WORD Appear.nextEntryPtr,Appear.list

    TC_END

UT_add1:
    call Appear.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Appear.add
    ld b, 50 : ld c, 32 : call Appear.add
    TEST_MEMORY_BYTE Appear.count,2
    TEST_MEMORY_BYTE Appear.list,42
    TEST_MEMORY_BYTE Appear.list + 1,55
    TEST_MEMORY_BYTE Appear.list + 2,50
    TEST_MEMORY_BYTE Appear.list + 3,32
    TC_END

;Make invisible
UT_setVisibility1:
    ;set up sprites
    call SpriteList.removeAll
    ld hl, .sprite1 : call SpriteList.addSprite
    ld hl, .sprite2 : call SpriteList.addSprite

    ;set up Appear data
    call Appear.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Appear.add
    ld b, 88 : ld c, 32 : call Appear.add

    ld a,0
    call Appear.setVisibility
    ;Check visibility is clear
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern, 5
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.pattern, 6
    TC_END

.sprite1:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 1, 200, 100, 0, 5 | SPRITE_VISIBILITY_MASK, 42, 0
.sprite2:
    spriteItem 2, 200, 100, 0, 6 | SPRITE_VISIBILITY_MASK, 88, 0

;Make visible
UT_setVisibility2:
    ;set up sprites
    call SpriteList.removeAll
    ld hl, .sprite1 : call SpriteList.addSprite
    ld hl, .sprite2 : call SpriteList.addSprite

    ;set up Appear data
    call Appear.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Appear.add
    ld b, 88 : ld c, 32 : call Appear.add

    ld a,1
    call Appear.setVisibility
    ;Check visibility is clear
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern, 5 | SPRITE_VISIBILITY_MASK
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.pattern, 6 | SPRITE_VISIBILITY_MASK
    TC_END

.sprite1:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 1, 200, 100, 0, 5 , 42, 0
.sprite2:
    spriteItem 2, 200, 100, 0, 6 , 88, 0

UT_update1:
    ;set up sprites
    call SpriteList.removeAll
    ld hl, .sprite1 : call SpriteList.addSprite
    ld hl, .sprite2 : call SpriteList.addSprite

    ;set up Appear data
    call Appear.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 1 : call Appear.add
    ld b, 88 : ld c, 2 : call Appear.add

    ld a,0
    call Appear.setVisibility
    call Appear.start
    ;First sprite should appear
    call Appear.update
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern, 5 | SPRITE_VISIBILITY_MASK
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.pattern, 6
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_APPEAR,a
    TEST_FLAG_Z

    ;Second sprite should appear
    call Appear.update
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern, 5 | SPRITE_VISIBILITY_MASK
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.pattern, 6 | SPRITE_VISIBILITY_MASK
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_APPEAR,a
    TEST_FLAG_NZ

    TC_END

.sprite1:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 1, 200, 100, 0, 5 | SPRITE_VISIBILITY_MASK, 42, 0
.sprite2:
    spriteItem 2, 200, 100, 0, 6 | SPRITE_VISIBILITY_MASK, 88, 0


    endmodule