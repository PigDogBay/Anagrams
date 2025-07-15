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
    call Tilemap.clear
    ;Remove all interaction from sprites
    call SpriteList.removeAllInteraction

    ld ix,timer1
    ld hl,100
    call Timing.startTimer

    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites

    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .leaveState

    ld a,(paletteOffset)
    inc a
    and %00001111
    ld (paletteOffset),a
    ld ix, (slotSpritePtr)
    ld (ix+spriteItem.palette),a
    ret

.leaveState:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ;Restore palette
    xor a
    ld ix, (slotSpritePtr)
    ld (ix+spriteItem.palette),a
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

slotSpritePtr:
    dw 0

paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule