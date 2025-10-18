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

    ; Print "Well Done!"
    ld d, 15
    ld e, 16
    ld hl,strWellDone
    call Print.setCursorPosition
    ld b,Tilemap.GOLD
    call Print.printString

    ;Print "You've Passed The Exam"
    ld d, 9
    ld e, 18
    ld hl,strYouPassed
    call Print.setCursorPosition
    ld b,Tilemap.GOLD
    call Print.printString

    ;Print "Click To Continue"
    ld d, 11
    ld e, 29
    ld hl,strClickToContinue
    call Print.setCursorPosition
    ld b,Tilemap.GREEN
    call Print.printString

    call FlashSprites.copyAllTileIds
    ld hl,600
    call FlashSprites.start

    call Sound.solved


    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    STOP_ALL_ANIMATION
    call GamePhases.solvedExit
    ld a,b
    cp GamePhases.PHASE_START
    jr z, .start
    cp GamePhases.PHASE_ROUND
    jr z, .round
    TRANSITION_SCREEN GS_WIN, IMAGE_WIN
    ret
.start:
    ld hl, GS_START
    call GameStateMachine.change
    ret
.round:
    TRANSITION_SCREEN GS_ROUND, IMAGE_ROUND
    ret

strWellDone:
    db "WELL DONE!",0
strYouPassed:
    db "YOU'VE PASSED THE EXAM",0
strClickToContinue:
    db "CLICK TO CONTINUE",0
    endmodule