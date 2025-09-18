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
    ;
    ;pick a random tile and find a matching slot
    ;
    call Tile.pickRandomTile
    ld a,h
    or l
    jr z, .notFound

    ;save tileStruct ptr    
    ld ix,hl


    ;IX points to tileStruct
    call Board.findEmptyMatchingSlot
    or a
    jr z, .notFound

    ld a,(ix+slotStruct.id)
    ld b,(iy+slotStruct.id)
    ld c, Game.LIFELINE_FLASH_DURATION
    call FlashTwo.start

.notFound:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

timer1:
    timingStruct 0,0,0

instructionText1:
    db "Thinking...",0

    endmodule