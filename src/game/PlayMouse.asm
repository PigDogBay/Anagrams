;-----------------------------------------------------------------------------------
;
; Module PlayMouse
;
; Handles mouse events when in the play state, eg dragging of tiles to slots
;
;-----------------------------------------------------------------------------------
    
    
    module PlayMouse

@QUIT_BUTTON:           equ 1
@LIFELINE_1_BUTTON:     equ 2
@LIFELINE_2_BUTTON:     equ 3
@LIFELINE_3_BUTTON:     equ 4
@LIFELINE_4_BUTTON:     equ 5
        
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
update:
    ld hl, jumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl

stateMouseReady:
    ; Do nothing
    ret
stateMouseHover:
    ; Do nothing
    ret
stateMouseHoverEnd:
    ; Do nothing
    ret
stateMousePressed:
    ; Do nothing
    ret
stateMouseClicked:
    ld a,c
    cp QUIT_BUTTON
    jr z, .quitClicked

    cp LIFELINE_1_BUTTON
    jr z, .lifeLine1Clicked

    cp LIFELINE_2_BUTTON
    jr z, .lifeLine2Clicked

    cp LIFELINE_3_BUTTON
    jr z, .lifeLine3Clicked

    cp LIFELINE_4_BUTTON
    jr z, .lifeLine4Clicked

.quitClicked:
    ; next state
    ld hl, GS_CONFIRM_QUIT
    call GameStateMachine.change
    ret

.lifeLine1Clicked:
    ret
.lifeLine2Clicked:
    ret
.lifeLine3Clicked:
    ret
.lifeLine4Clicked:
    ld hl, GS_LIFELINE_CLUE
    call GameStateMachine.change
    ret


stateMouseDragStart:
    ;bring the sprite to the front
    ;bringToFront In: IX points to spriteItem and will be swapped with the front most sprite
    ;bringToFrontOut: IX will now point to the front most sprite
    call SpriteList.bringToFront
    call Mouse.dragStart
    ;Unslot the tile incase it was alreay in a slot
    ld a, (ix+spriteItem.gameId)
    call Slot.unslotTile

    ;Update mouse pointer pattern
    ld a,1
    ld (SpriteList.list + spriteItem.pattern),a

    ret

stateMouseDrag:
    ; DRAG update, dragged sprite is at index[1]
    ld ix,SpriteList.list + spriteItem
    call Mouse.dragSprite
    call Tile.boundsCheck
    ret nz
    ; Tile was out of bounds
    ; Need to tell mouse state machine
    call MouseDriver.dragOutOfBounds
    ret

stateMouseDragOutOfBounds:
    ;Update mouse pointer pattern
    ld a,0
    ld (SpriteList.list + spriteItem.pattern),a
    ret

stateMouseDragEnd:
    ;Update mouse pointer pattern
    ld a,0
    ld (SpriteList.list + spriteItem.pattern),a
    ld hl, (dragEndCallback)
    jp (hl)

stateMouseClickedOff:
    ; Do nothing
    ret

stateMouseBackgroundPressed:
    ; Do nothing
    ret

stateMouseBackgroundClicked:
    ; Do nothing
    ret



nullDragEndCallback:
    ret

dragEndCallback:
    dw nullDragEndCallback

    endmodule