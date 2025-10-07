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
    ;Animation to clear the clue
    ld a,CLUE_TIMEOUT
    ld b,CLUE_ROW
    call ClearText.start

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
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

    endmodule