;-----------------------------------------------------------------------------------
; 
; State: Game Over
; 
; Game Over when the player is out of time
; 
;-----------------------------------------------------------------------------------

    module GameState_GameOver

@GS_GAME_OVER: 
    stateStruct enter,update

TITLE_Y equ 22
TITLE_Y2 equ 44

enter:
    L2_SET_IMAGE IMAGE_DROPOUT
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
    call Sound.playDroppedOutMusic
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

    ld e, 9
    call College.getCollegeName
    ld b,Tilemap.WHITE
    call Print.printCentred

    ld de,Print.buffer
    call YearTerm.printShortToBuffer
    ;Print the buffer to the screen
    ld hl,Print.buffer
    ld e, 11
    ld b,Tilemap.WHITE
    call Print.printCentred

    ld e, 17
    ld hl,tauntText
    call Print.setCursorPosition
    ld b,Tilemap.WHITE
    call Print.printCentred

    ; Click to exit
    ld e, 29
    ld hl,startInstruction
    call Print.setCursorPosition
    ld b,Tilemap.WHITE
    call Print.printCentred
    ret

tauntText:
    db "YOU DID NOT MEET EXPECTATIONS",0

startInstruction:
    db "CLICK TO LEAVE",0


spriteData:
    db 11
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,90,TITLE_Y,0,'D'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,110,TITLE_Y,0, 'R'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,130,TITLE_Y,0,'O'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,150,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,170,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,190,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,210,TITLE_Y,0,'D'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,130,TITLE_Y2,0,'O'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,150,TITLE_Y2,0,'U'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,170,TITLE_Y2,0,'T'-Tile.ASCII_PATTERN_OFFSET,10,0

spriteLen: equ $ - spriteData

    endmodule