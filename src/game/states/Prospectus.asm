;-----------------------------------------------------------------------------------
; 
; State: Level Select
; 
; Choose the level to play
; 
;-----------------------------------------------------------------------------------

    module GameState_Prospectus

@GS_PROSPECTUS: 
    stateStruct enter,update


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a,6
    call Graphics.fillLayer2_320
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Tile.removeAll
    ld hl,titleText
    ld c, 16
    call Tile.createTiles
    call Tile.tilesToSprites

    ld d, 3
    ld e, 11
    ld hl,strSelectUniversity
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 14
    ld e, 13
    ld hl,strUniversity
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 12
    ld e, 15
    ld hl,strMotto
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 3
    ld e, 20
    ld hl,strSelectYear
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 10
    ld e, 22
    ld hl,strYear
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 7
    ld e, 29
    ld hl,strClickToStart
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ;Animated Sprite Tile
    ;Add slots and amke SYLLABUS tiles appear

    ld bc, spriteLen
    ld de, SpriteList.count
    ld hl, spriteData
    ldir
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 1 : ld c, 14 : call Visibility.add
    ld b, 2 : ld c, 18: call Visibility.add
    ld b, 3 : ld c, 22 : call Visibility.add
    ld b, 4 : ld c, 26 : call Visibility.add
    ld b, 5 : ld c, 30 : call Visibility.add
    ld b, 6 : ld c, 34 : call Visibility.add
    ld b, 7 : ld c, 38 : call Visibility.add
    ld b, 8 : ld c, 42 : call Visibility.add
    ld b, 9 : ld c, 46 : call Visibility.add
    ld b, 10 : ld c, 50 : call Visibility.add
    call Visibility.start



    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    ld hl,$0101
    call Puzzles.select
    ld hl, GS_ROUND
    call GameStateMachine.change
    ret

titleText:
    db "PROSPECTUS",0
strSelectUniversity:
    db "Select University",0
strUniversity:
    db "St Edmund Hall",0
strMotto:
    db "Aula Sancti Edmundi",0
strClickToStart:
    db "Click to begin your studies",0

strSelectYear:
    db "Entry Year",0
strYear:
    db "1st Year Undergrad",0

spriteData:
    db 17
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
     spriteItem 1,81,33,0,'S'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,101,33,0,'Y'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,121,33,0,'L'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,141,33,0,'L'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,161,33,0,'A'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,181,33,0,'B'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,201,33,0,'U'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,221,33,0,'S'-Tile.ASCII_PATTERN_OFFSET,8,0

    ;Slots
    spriteItem 11,80,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,11,0
    spriteItem 12,100,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,12,0
    spriteItem 13,120,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,13,0
    spriteItem 14,140,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,14,0
    spriteItem 15,160,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,15,0
    spriteItem 16,180,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,16,0
    spriteItem 17,200,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,17,0
    spriteItem 18,220,32,0,Slot.SLOT_SPRITE_PATTERN | SPRITE_VISIBILITY_MASK,18,0

spriteLen: equ $ - spriteData

    endmodule