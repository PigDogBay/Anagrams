;-----------------------------------------------------------------------------------
; 
; State: LifelineSlot
; 
; Select a slot, reveal which tile(s) can fit 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module GameState_LifelineSlot

INSTRUCTION_ROW: equ 28

@GS_LIFELINE_SLOT:
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
    ;Make the slot sprites clickable, to allow user to select one of them
    call SpriteList.allSlotsClickable


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
    ;get slot's ptr
    ld a,c
    call Slot.find
    ld a,h
    or l
    jr z, .notFound

    ;save slotStruct ptr    
    ld ix,hl

    ;IX points to slotStruct
    ld a,(ix+slotStruct.letter)
    call Tile.findByLetter
    ld a,h
    or l
    jr z, .notFound

    ;HL already points to gameId
    ld a, (hl)
    ld b, (ix+slotStruct.id)
    ld c, Game.LIFELINE_FLASH_DURATION
    call FlashTwo.start

    ld a,(Lifelines.costSlot)
    call GameState_Play.deductTime


.notFound:
    ; Restore interaction flags
    call SpriteList.restoreAllInteraction
    ld hl, GS_PLAY
    call GameStateMachine.change
    ret



instructionText1:
    db "Select a Slot",0
instructionText2:
    db "To Reveal Matching Tile",0

    endmodule