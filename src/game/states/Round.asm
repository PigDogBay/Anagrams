;-----------------------------------------------------------------------------------
; 
; State: Round
; 
; Displays information about the current level, round and upcoming puzzle
; 
;-----------------------------------------------------------------------------------

    module GameState_Round

@GS_ROUND: 
    stateStruct enter,update

TITLE_Y equ 30
TITLE_Y2 equ 50


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer


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
    ld b, 11 : ld c, 54 : call Visibility.add
    ld b, 12 : ld c, 58 : call Visibility.add
    ld b, 13 : ld c, 62 : call Visibility.add
    call Visibility.start
    jp printText

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    ld hl, GS_START
    call GameStateMachine.change
    ret


printText:
    call Tilemap.clear

    ; College
    ld e, 12
    call Puzzles.getCollegeName
    ld b,%00000000
    call Print.printCentred

    ; Year 
    ld e, 14
    call Puzzles.getYearName
    ld b,%0000000
    call Print.printCentred

    ; Difficulty
    ld e, 16
    call Puzzles.getDifficultyName
    ld b,%0000000
    call Print.printCentred

    ld e, 23
    call Puzzles.getCategory
    call Puzzles.categoryToString
    ld b,%0000000
    call Print.printCentred


    ; Click to continue
    ld e, 29
    ld hl,startInstruction
    ld b,%00010000
    call Print.printCentred
    ret



startInstruction:
    db "CLICK TO BEGIN YOUR STUDIES",0


spriteData:
    db 13
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,90,TITLE_Y,0,'L'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,110,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,130,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,150,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,170,TITLE_Y,0,'U'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,190,TITLE_Y,0,'R'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,210,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,110,TITLE_Y2,0,'N'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,130,TITLE_Y2,0,'O'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,150,TITLE_Y2,0,'T'-Tile.ASCII_PATTERN_OFFSET,10,0
    spriteItem 11,170,TITLE_Y2,0,'E'-Tile.ASCII_PATTERN_OFFSET,11,0
    spriteItem 12,190,TITLE_Y2,0,'S'-Tile.ASCII_PATTERN_OFFSET,12,0

spriteLen: equ $ - spriteData

    endmodule