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
    ld b,%00100000
    call Print.printString

    ;Print "You've Passed The Exam"
    ld d, 9
    ld e, 18
    ld hl,strYouPassed
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ;Print "Click To Continue"
    ld d, 11
    ld e, 29
    ld hl,strClickToContinue
    call Print.setCursorPosition
    ;Green
    ld b,%00010000
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
    call GameStateMachine.change
    ret

strWellDone:
    db "Well Done!",0
strYouPassed:
    db "You've Passed The Exam",0
strClickToContinue:
    db "Click to Continue",0
    endmodule