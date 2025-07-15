;-----------------------------------------------------------------------------------
; 
; State: LifelineTile
; 
; Select a tile, reveal which slot it belongs to 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineTile

INSTRUCTION_ROW: equ 2

@GS_LIFELINE_TILE:
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
    ;Make the tile sprites to clickable, to allow user to select one of them
    call SpriteList.allTilesClickable


    ret




update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call mouseStateHandler
    call Game.updateSprites
    ret



jumpTable:
    dw stateMouseReady
    dw stateMouseHover
    dw stateMouseHoverEnd
    dw stateMousePressed
    dw stateMouseClicked
    dw stateMouseDragStart
    dw stateMouseDrag
    dw stateMouseDragOutOfBounds
    dw stateMouseDragEnd
    dw stateMouseClickedOff
    dw stateMouseBackgroundPressed
    dw stateMouseBackgroundClicked

;-----------------------------------------------------------------------------------
;
; Function: mouseStateHandler
;
; Updates the game based on the current mouse state 
; In - A current mouse state
;    - IX pointer to sprite that mouse is over
;-----------------------------------------------------------------------------------
mouseStateHandler:
    ld hl, jumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl

stateMouseReady:
stateMouseHover:
stateMouseHoverEnd:
stateMousePressed:
stateMouseDrag:
stateMouseDragOutOfBounds:
stateMouseDragEnd:
stateMouseClickedOff:
stateMouseBackgroundPressed:
stateMouseDragStart:
    ret

stateMouseBackgroundClicked:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ; Cancel Lifeline
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret

stateMouseClicked:
    ;get tile gameId
    ld a,c
    call Tile.find
    ld a,h
    or l
    jr z, .slotNotFound
    ld ix,hl
    call Board.findEmptyMatchingSlot
    or a
    jr z, .slotNotFound

    ld a,(iy+slotStruct.id)
    call SpriteList.find
    ld a,h
    or l
    jr z, .slotNotFound

    ;Found matching slot
    ld (GameState_HighlightSlot.slotSpritePtr),hl
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_HIGHLIGHT_SLOT
    call GameStateMachine.change
    ret

.slotNotFound:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_HIGHLIGHT_SLOT
    call GameStateMachine.change
    ret


instructionText1:
    db "Select a Tile",0
instructionText2:
    db "To Reveal Matching Slot",0

    endmodule