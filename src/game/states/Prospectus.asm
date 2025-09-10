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

TITLE_Y equ 30

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
    call Visibility.start
    jp printText


update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    call Keyboard.getMenuChar
    or a
    jp nz, keyPressed
    ret

.mousePressed:
    ld hl,$0101
    call Puzzles.select
    call Puzzles.resetMoney
    ld hl, GS_START
    call GameStateMachine.change
    ret

;
; A = 1,2 or 3
;
keyPressed:
    cp 1
    jr z, .pressed1
    cp 2
    jr z, .pressed2
    cp 3
    jr z, .pressed3
    ret
.pressed1:
    call Puzzles.nextCollege
    jp printText
.pressed2:
    call Puzzles.nextYearSelect
    jp printText
.pressed3:
    call Puzzles.nextDifficulty
    jp printText




printText:
    call Tilemap.clear
    ld d, 9
    ld e, 7
    ld hl,universityText
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ; College Selector
    ld d, 6
    ld e, 12
    ld hl,selectText1
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 9
    ld e, 12
    call Print.setCursorPosition
    call Puzzles.getCollegeName
    ld b,%00000000
    call Print.printString

    ;Year Selector
    ld d, 6
    ld e, 14
    ld hl,selectText2
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 9
    ld e, 14
    call Print.setCursorPosition
    call Puzzles.getYearName
    ld b,%0000000
    call Print.printString

    ;Difficulty Selector
    ld d, 6
    ld e, 16
    ld hl,selectText3
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 9
    ld e, 16
    call Print.setCursorPosition
    call Puzzles.getDifficultyName
    ld b,%0000000
    call Print.printString

    ;1,2 or 3 instruction
    ld d, 4
    ld e, 21
    ld hl,settingsInstruction
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString


    ; Click to continue
    ld d, 13
    ld e, 29
    ld hl,startInstruction
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString
    ret

universityText:
    db "UNIVERSITY OF OXBRIDGE",0

selectText1:
    db "1. ",0    
selectText2:
    db "2. ",0    
selectText3:
    db "3. ",0    

settingsInstruction:
    db "PRESS 1,2 OR 3 TO CYCLE OPTIONS",0

startInstruction:
    db "CLICK TO ENROL",0


spriteData:
    db 11
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,61,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,81,TITLE_Y,0, 'R'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,101,TITLE_Y,0,'O'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,121,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,141,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,161,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,181,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,201,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,221,TITLE_Y,0,'U'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,241,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,10,0

spriteLen: equ $ - spriteData

    endmodule