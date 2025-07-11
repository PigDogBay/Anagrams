;-----------------------------------------------------------------------------------
; 
; State: LifeLineClue
; 
; Clue life line has been activated, click mouse to exit back to Play
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineClue

@GS_LIFELINE_CLUE:
    stateStruct enter,update


enter:
    ; Display Clue
    call Puzzles.getClue
    ld d, 10
    ld e, 18
    call Print.setCursorPosition
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
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

    endmodule