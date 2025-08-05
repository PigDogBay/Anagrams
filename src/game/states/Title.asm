;-----------------------------------------------------------------------------------
; 
; State: Title
; 
; Shows title screen
; 
;-----------------------------------------------------------------------------------

    module GameState_Title

TITLE_STATE_START:                      equ 0
TITLE_STATE_FADE_IN:                    equ 1
TITLE_STATE_MOVE_TILES:                 equ 2
TITLE_STATE_FLASH:                      equ 3
TITLE_STATE_FADE_OUT:                   equ 4
stateJumpTable:
    dw titleStart
    dw titleFadeIn
    dw titleMoveTiles
    dw titleFlash
    dw titleFadeOut


@GS_TITLE: 
    stateStruct enter,update


enter:
    call Graphics.titleScreen
    ld a,TITLE_STATE_START
    ld (titleState),a
    call Tilemap.clear
    call NextSprite.removeAll
    call SpriteList.removeAll

    ret

    ;Fade in slots
initAppear:
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 11 : ld c, 5 : call Visibility.add
    ld b, 12 : ld c, 10: call Visibility.add
    ld b, 13 : ld c, 15 : call Visibility.add
    ld b, 14 : ld c, 20 : call Visibility.add
    ld b, 15 : ld c, 25 : call Visibility.add
    ld b, 16 : ld c, 30 : call Visibility.add
    ld b, 17 : ld c, 35 : call Visibility.add
    ld b, 18 : ld c, 40 : call Visibility.add
    ld b, 19 : ld c, 45 : call Visibility.add
    ld b, 20 : ld c, 50 : call Visibility.add
    ld b, 1 : ld c, 52 : call Visibility.add
    ld b, 2 : ld c, 54: call Visibility.add
    ld b, 3 : ld c, 56 : call Visibility.add
    ld b, 4 : ld c, 58 : call Visibility.add
    ld b, 5 : ld c, 60 : call Visibility.add
    ld b, 6 : ld c, 62 : call Visibility.add
    ld b, 7 : ld c, 64 : call Visibility.add
    ld b, 8 : ld c, 66 : call Visibility.add
    ld b, 9 : ld c, 68 : call Visibility.add
    ld b, 10 : ld c, 70 : call Visibility.add
    call Visibility.start
    ret

initDisappear:
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 1 : ld c, 1 : call Visibility.add
    ld b, 2 : ld c, 1 : call Visibility.add
    ld b, 3 : ld c, 1 : call Visibility.add
    ld b, 4 : ld c, 1 : call Visibility.add
    ld b, 5 : ld c, 1 : call Visibility.add
    ld b, 6 : ld c, 1 : call Visibility.add
    ld b, 7 : ld c, 1 : call Visibility.add
    ld b, 8 : ld c, 1 : call Visibility.add
    ld b, 9 : ld c, 1 : call Visibility.add
    ld b, 10 : ld c, 1 : call Visibility.add
    ld b, 11 : ld c, 1 : call Visibility.add
    ld b, 12 : ld c, 1: call Visibility.add
    ld b, 13 : ld c, 1 : call Visibility.add
    ld b, 14 : ld c, 1 : call Visibility.add
    ld b, 15 : ld c, 1 : call Visibility.add
    ld b, 16 : ld c, 1 : call Visibility.add
    ld b, 17 : ld c, 1 : call Visibility.add
    ld b, 18 : ld c, 1 : call Visibility.add
    ld b, 19 : ld c, 1 : call Visibility.add
    ld b, 20 : ld c, 1 : call Visibility.add
    call Visibility.start
    ret

initMoveTiles:
    ld ix, motionData
    ld b, 10
    call MoveSprites.removeAll
.loop:
    push bc
    call MoveSprites.add
    ld de, motionStruct
    add ix,de
    pop bc
    djnz .loop
    call MoveSprites.start
    ret

initFlash:
    xor a
    ld (FlashSprites.index),a
    ld hl, FlashSprites.idList
    ld b,10
    ld a,1
.loop:
    ld (hl),a
    inc hl
    inc a
    djnz .loop
    ld (hl),0

    ld hl,300
    call FlashSprites.start

    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    jr titleStateUpdate

.mousePressed:
    STOP_ALL_ANIMATION
    ld hl, GS_LEVEL_SELECT
    call GameStateMachine.change
    ret


titleStateUpdate:
    ld a,(titleState)
    ld hl, stateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl


titleStart:
    call NextSprite.removeAll
    call Tilemap.clear

    ld bc, spriteLen
    ld de, SpriteList.count
    ld hl, spriteData
    ldir

    call initAppear
    ld a,TITLE_STATE_FADE_IN
    ld (titleState),a
    ret

titleFadeIn:
    ;wait for fade in to finish
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_APPEAR, a
    ret z
    ld a,TITLE_STATE_MOVE_TILES
    ld (titleState),a
    call initMoveTiles

    ld d, 10
    ld e, 29
    ld hl,instruction
    call Print.setCursorPosition
    ld b,0
    call Print.printString


    ret

titleMoveTiles:
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_MOVE, a
    ret z
    call initFlash
    ld a,TITLE_STATE_FLASH
    ld (titleState),a

    ; Print "By Pig Dog Bay"
    ld d, 13
    ld e, 16
    ld hl,author
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ret

titleFlash:
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_FLASH_SPRITES, a
    ret z
    call initDisappear
    ld a,TITLE_STATE_FADE_OUT
    ld (titleState),a
    ret

titleFadeOut:
    ;wait for fade in to finish
    ld a, (Animator.finishedFlags)
    bit Animator.BIT_APPEAR, a
    ret z
    ld a,TITLE_STATE_START
    ld (titleState),a
    ret

titleState:
    db TITLE_STATE_START

author:
    db "BY PIG DOG BAY",0
    db "By Pig Dog Bay",0

instruction:
    db "Click Mouse To Begin",0

spriteData:
    db 21
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 5,111,171,0,'C'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 10,131,171,0,'R'-Tile.ASCII_PATTERN_OFFSET,10,0
    spriteItem 9,151,171,0,'A'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 4,171,171,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 2,191,171,0,'H'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 6,111,195,0,'H'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,131,195,0,'O'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 1,151,195,0,'T'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 3,171,195,0,'E'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 8,191,195,0,'L'-Tile.ASCII_PATTERN_OFFSET,8,0

    ;Slots
    spriteItem 11,130,48,0,Slot.SLOT_SPRITE_PATTERN,11,0
    spriteItem 12,150,48,0,Slot.SLOT_SPRITE_PATTERN,12,0
    spriteItem 13,170,48,0,Slot.SLOT_SPRITE_PATTERN,13,0
    spriteItem 14,90,72,0,Slot.SLOT_SPRITE_PATTERN,14,0
    spriteItem 15,110,72,0,Slot.SLOT_SPRITE_PATTERN,15,0
    spriteItem 16,130,72,0,Slot.SLOT_SPRITE_PATTERN,16,0
    spriteItem 17,150,72,0,Slot.SLOT_SPRITE_PATTERN,17,0
    spriteItem 18,170,72,0,Slot.SLOT_SPRITE_PATTERN,18,0
    spriteItem 19,190,72,0,Slot.SLOT_SPRITE_PATTERN,19,0
    spriteItem 20,210,72,0,Slot.SLOT_SPRITE_PATTERN,20,0

spriteLen: equ $ - spriteData

motionData:
    ; gameId, stepX, countX, stepY, countY, delay 
    motionStruct 1, 2, 131, 2, 49, 75 
    motionStruct 2, 2, 151, 2, 49, 150
    motionStruct 3, 2, 171, 2, 49, 175 
    motionStruct 4, 2, 91, 2, 73, 200
    motionStruct 5, 2, 111, 2, 73, 225 
    motionStruct 6, 2, 131, 2, 73, 25 
    motionStruct 7, 2, 151, 2, 73, 100 
    motionStruct 8, 2, 171, 2, 73, 50 
    motionStruct 9, 2, 191, 2, 73, 125 
    motionStruct 10, 2, 211, 2, 73, 250 

    endmodule