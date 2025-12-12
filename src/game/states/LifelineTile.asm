;-----------------------------------------------------------------------------------
; 
; State: LifelineTile
; 
; Select a tile, reveal which slot it belongs to 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineTile

INSTRUCTION_ROW: equ 28

@GS_LIFELINE_TILE:
    stateStruct enter,update


enter:
    ; Display instruction
    ld hl,instructionText1
    ld e, INSTRUCTION_ROW
    call Game.printInstruction
    ld hl,instructionText2
    ld e, INSTRUCTION_ROW + 2
    call Game.printInstruction

    ;Remove all interaction from sprites
    call SpriteList.removeAllInteraction
    ;Make the tile sprites to clickable, to allow user to select one of them
    call SpriteList.allTilesClickable

    ret




update:
    call GamePhases.playUpdate
    jp z, GameState_Play.gameOver
    ;wait for use to click mouse button
    call Game.updateMouse
    call mouseStateHandler
    call Game.updateSprites
    call GameState_Play.printTime
    ret



jumpTable:
    dw stateMouseReady
    dw stateMouseHover
    dw stateMouseHoverEnd
    dw stateMousePressed
    dw stateMousePressedRight
    dw stateMouseClicked
    dw stateMouseClickedRight
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
stateMousePressedRight:
stateMouseClickedRight:
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
    call Sound.cancel
    ret

stateMouseClicked:
    ;get tile gameId
    ld a,c
    call Tile.find
    ld a,h
    or l
    jr z, .slotNotFound

    ld ix,hl
    ;IX points to tileStruct
    call Board.findEmptyMatchingSlot
    or a
    jr z, .slotNotFound

    ;Set up animation
    ;FlashTwo requires two game IDs in A and B
    ld a,(ix+tileStruct.id)
    ld b,(iy+slotStruct.id)
    ld c, Game.LIFELINE_FLASH_DURATION
    call FlashTwo.start

    ld a,(Lifelines.costTile)
    call GameState_Play.deductTime
    call Sound.highlight


.slotNotFound:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret


instructionText1:
    db "SELECT A TILE",0
instructionText2:
    db "TO REVEAL MATCHING SLOT",0

    endmodule