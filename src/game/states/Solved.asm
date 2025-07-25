;-----------------------------------------------------------------------------------
; 
; State: solved
; 
; Sets up a new puzzle to solved
; 
;-----------------------------------------------------------------------------------

    module GameState_Solved

@GS_SOLVED: 
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

    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_PRESSED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    call Puzzles.nextRound
    or a
    jr nz, .start
    
    call Puzzles.nextLevel
    or a
    jr nz, .start
    
    //TODO GS_GAME_COMPLETED, for now go back to level 1
    ld hl,$0101
    call Puzzles.select

.start:
    ld hl, GS_START
    call GameStateMachine.change
    ret

titleText:
    db "SOLVED",0


    endmodule