;-----------------------------------------------------------------------------------
; 
; State: LifelineSlot
; 
; Select a slot, reveal which tile(s) can fit 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineSlot

INSTRUCTION_ROW: equ 2

@GS_LIFELINE_SLOT:
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
    db "Select a Slot",0
instructionText2:
    db "To Reveal Matching Tile",0

    endmodule