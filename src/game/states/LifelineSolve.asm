;-----------------------------------------------------------------------------------
; 
; State: LifelineSolve
; 
; Pick a random tile  (must be unslotted, or incorrectly placed) 
; Move to a matching slot, if slot is occuppied bounce incorrect tile or find next matching slot
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

instructionText1:
    db "Placing a Tile",0
instructionText2:
    db "For You",0

    endmodule