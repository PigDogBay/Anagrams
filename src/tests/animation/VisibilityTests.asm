    module TestSuite_Appear

UT_removeAll1:
    call Visibility.removeAll
    TEST_MEMORY_BYTE Visibility.count,0
    TEST_MEMORY_WORD Visibility.nextEntryPtr,Visibility.list

    TC_END

UT_add1:
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Visibility.add
    ld b, 50 : ld c, 32 : call Visibility.add
    TEST_MEMORY_BYTE Visibility.count,2
    TEST_MEMORY_BYTE Visibility.list,42
    TEST_MEMORY_BYTE Visibility.list + 1,55
    TEST_MEMORY_BYTE Visibility.list + 2,50
    TEST_MEMORY_BYTE Visibility.list + 3,32
    TC_END

;Make invisible
UT_setVisibility1:
    ;set up sprites
    call SpriteList.removeAll
    ld hl, .sprite1 : call SpriteList.addSprite
    ld hl, .sprite2 : call SpriteList.addSprite

    ;set up Appear data
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Visibility.add
    ld b, 88 : ld c, 32 : call Visibility.add

    ld a,0
    call Visibility.setVisibility
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
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 55 : call Visibility.add
    ld b, 88 : ld c, 32 : call Visibility.add

    ld a,1
    call Visibility.setVisibility
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
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 42 : ld c, 1 : call Visibility.add
    ld b, 88 : ld c, 2 : call Visibility.add

    ld a,0
    call Visibility.setVisibility
    call Visibility.start
    ;First sprite should appear
    call Visibility.update
    TEST_MEMORY_BYTE SpriteList.list + spriteItem.pattern, 5 | SPRITE_VISIBILITY_MASK
    TEST_MEMORY_BYTE SpriteList.list + spriteItem + spriteItem.pattern, 6
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_APPEAR,a
    TEST_FLAG_Z

    ;Second sprite should appear
    call Visibility.update
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