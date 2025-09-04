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
    call Tilemap.clear
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    ; call Tile.removeAll
    ; ld hl,titleText
    ; ld c, 10
    ; call Tile.createTiles
    ; call Tile.tilesToSprites

    ld d, 9
    ld e, 7
    ld hl,universityText
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ld d, 6
    ld e, 12
    ld hl,selectText1
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 6
    ld e, 14
    ld hl,selectText2
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 6
    ld e, 16
    ld hl,selectText3
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString

    ld d, 4
    ld e, 20
    ld hl,settingsInstruction
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString


    ld d, 8
    ld e, 29
    ld hl,startInstruction
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


universityText:
    db "UNIVERSITY OF OXBRIDGE",0

selectText1:
    db "1>",0    
selectText2:
    db "2>",0    
selectText3:
    db "3>",0    

settingsInstruction:
    db "PRESS 1,2 OR 3 TO CYCLE SETTINGS",0

startInstruction:
    db "CLICK TO BEGIN YOUR STUDIES",0


spriteData:
    db 11
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,61,33,0,'P'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,81,33,0, 'R'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,101,33,0,'O'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,121,33,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,141,33,0,'P'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,161,33,0,'E'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,181,33,0,'C'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,201,33,0,'T'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,221,33,0,'U'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,241,33,0,'S'-Tile.ASCII_PATTERN_OFFSET,10,0

spriteLen: equ $ - spriteData

    endmodule