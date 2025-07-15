;-----------------------------------------------------------------------------------
; 
; State: LifelineTile
; 
; Select a tile, reveal which slot it belongs to 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module GameState_HighlightSlot

@GS_HIGHLIGHT_SLOT:
    stateStruct enter,update


enter:
    ;Remove all interaction from sprites
    call SpriteList.removeAllInteraction
    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites

    ld hl, GS_PLAY
    call GameStateMachine.change
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ret

selectedSlot:
    dw 0

    endmodule