;-----------------------------------------------------------------------------------
; 
; State: LifelineSolve
; 
; Picks a random tile and finds a matching slot
;
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineSolve

INSTRUCTION_ROW: equ 2

@GS_LIFELINE_SOLVE:
    stateStruct enter,update


enter:
    ; Display instruction
    ld hl,instructionText1
    ld e, INSTRUCTION_ROW
    call Game.printInstruction
    ld hl,instructionText2
    ld e, INSTRUCTION_ROW + 1
    call Game.printInstruction

    ;Remove all interaction from sprites
    call SpriteList.removeAllInteraction

    ld ix,timer1
    ld hl,75
    call Timing.startTimer

    ret



update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites
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

    ;Find sprite and save it in HighlightSlot state
    ld a,(ix+tileStruct.id)
    call SpriteList.find
    ld a,h
    or l
    jr z, .notFound
    ;Found tile sprite
    ld (GameState_HighlightSlot.tileSpritePtr),hl

    ;IX points to tileStruct
    call Board.findEmptyMatchingSlot
    or a
    jr z, .notFound

    ld a,(iy+slotStruct.id)
    call SpriteList.find
    ld a,h
    or l
    jr z, .notFound

    ;Found matching slot
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld (GameState_HighlightSlot.slotSpritePtr),hl
    ld hl, GS_HIGHLIGHT_SLOT
    call GameStateMachine.change
    ret

.notFound:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

timer1:
    timingStruct 0,0,0

instructionText1:
    db "Picking a random tile",0
instructionText2:
    db "and finding its slot...",0

    endmodule