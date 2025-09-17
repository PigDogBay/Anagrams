;-----------------------------------------------------------------------------------
; 
; State: Win
; 
; Player was won the game
; 
;-----------------------------------------------------------------------------------

    module GameState_Win

@GS_WIN: 
    stateStruct enter,update

TITLE_Y equ 30
TITLE_Y2 equ 50

enter:
    ld a,83
    call Graphics.fillLayer2_320
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
    ret

.mousePressed:
    ; next state
    ld hl, GS_TITLE
    call GameStateMachine.change
    ret

printText:
    call Tilemap.clear

    ld e, 10
    ld hl,ofText
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printCentred

    ; College
    ld e, 13
    call College.getCollegeName
    ld b,%00000000
    call Print.printCentred

    ld e, 18
    ld hl,wellDoneText2
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printCentred

    ld e, 21
    ld hl,wellDoneText3
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printCentred


    ; Click to exit
    ld e, 29
    ld hl,startInstruction
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printCentred
    ret

ofText:
    db "OF",0

wellDoneText1:
    db "MOST EXCELLENT!",0
wellDoneText2:
    db "YOU HAVE ACHIEVED SCHOLARLY KNOWLEDGE",0
wellDoneText3:
    db "GO FORTH AND SHAKE THE WORLD",0

startInstruction:
    db "CLICK FOR GLORY",0


spriteData:
    db 11
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,130,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,150,TITLE_Y,0, 'H'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,170,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,90,TITLE_Y2,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,110,TITLE_Y2,0,'C'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,130,TITLE_Y2,0,'H'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,150,TITLE_Y2,0,'O'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,170,TITLE_Y2,0,'L'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,190,TITLE_Y2,0,'A'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,210,TITLE_Y2,0,'R'-Tile.ASCII_PATTERN_OFFSET,10,0

spriteLen: equ $ - spriteData

    endmodule