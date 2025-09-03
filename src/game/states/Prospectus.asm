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
    ld e, 8
    ld hl,strSelectUniversity
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 14
    ld e, 10
    ld hl,strUniversity
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 12
    ld e, 12
    ld hl,strMotto
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 3
    ld e, 16
    ld hl,strSelectYear
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 10
    ld e, 18
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
    endmodule