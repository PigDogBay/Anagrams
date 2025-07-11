;-----------------------------------------------------------------------------------
; 
; State: LifeLineClue
; 
; Clue life line has been activated, click mouse to exit back to Play
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineClue

CLUE_ROW: equ 17

@GS_LIFELINE_CLUE:
    stateStruct enter,update


enter:
    ; Display Clue
    call Puzzles.getClue
    ; Centre clue
    call String.len
    neg
    add 40
    sra a
    ld d, a
    ld e, CLUE_ROW
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