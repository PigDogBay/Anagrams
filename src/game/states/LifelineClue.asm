;-----------------------------------------------------------------------------------
; 
; State: LifeLineClue
; 
; Clue life line has been activated, click mouse to exit back to Play
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineClue

CLUE_ROW: equ 29
; 5 seconds
CLUE_TIMEOUT equ 50 * 5

@GS_LIFELINE_CLUE:
    stateStruct enter,update


enter:
    ld ix,timer1
    ld hl,CLUE_TIMEOUT
    call Timing.startTimer

    ; Display Clue
    ld hl, Puzzles.clue
    ld e, CLUE_ROW
    ld b,%00000000
    call Print.printCentred

    ld a,(Lifelines.costClue)
    call GameState_Play.deductTime
    ret

update:
    call GamePhases.playUpdate
    jp z, GameState_Play.gameOver
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    call GameState_Play.printTime
    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .mousePressed
    ret

.mousePressed:
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

timer1:
    timingStruct 0,0,0

    endmodule