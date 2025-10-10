;-----------------------------------------------------------------------------------
; 
; State: LifelineSolve
; 
; Picks a random tile and finds a matching slot
;
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineSolve

INSTRUCTION_ROW: equ 28

@GS_LIFELINE_SOLVE:
    stateStruct enter,update


enter:
    ; Display instruction
    ld hl,instructionText1
    ld e, INSTRUCTION_ROW
    call Game.printInstruction

    ;Remove all interaction from sprites
    call SpriteList.removeAllInteraction

    ld ix,timer1
    ld hl,75
    call Timing.startTimer

    ret



update:
    call GamePhases.playUpdate
    jp z, GameState_Play.gameOver
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites
    call GameState_Play.printTime
    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, solve
    ret



solve:
    call Lifelines.matchRandomTileAndSlot
    jr z, .error

    ld a,(ix+tileStruct.id)
    ld b,(iy+slotStruct.id)
    ld c, Game.LIFELINE_FLASH_DURATION
    call FlashTwo.start

    ld a,(Lifelines.costRand)
    call GameState_Play.deductTime
    call Sound.highlight

.exit:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret
.error:
    call Sound.error
    jr .exit



timer1:
    timingStruct 0,0,0

instructionText1:
    db "THINKING...",0

    endmodule