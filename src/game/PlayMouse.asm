;-----------------------------------------------------------------------------------
;
; Module PlayMouse
;
; Handles mouse events when in the play state, eg dragging of tiles to slots
;
;-----------------------------------------------------------------------------------
    
    
    module PlayMouse

TOOL_TIP_LINE1      equ 28
TOOL_TIP_LINE2      equ 30
       
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
    ld a,c
    cp QUIT_BUTTON
    jp z, printQuitTip

    cp LIFELINE_1_BUTTON
    jp z, printTipLifeLine1

    cp LIFELINE_2_BUTTON
    jp z, printTipLifeLine2

    cp LIFELINE_3_BUTTON
    jp z, printTipLifeLine3

    cp LIFELINE_4_BUTTON
    jp z, printTipLifeLine4
    ret

stateMouseHoverEnd:
    ld e, TOOL_TIP_LINE1
    call Print.clearLine
    ld e, TOOL_TIP_LINE2
    call Print.clearLine
    ret
stateMousePressed:
    ld e, TOOL_TIP_LINE1
    call Print.clearLine
    ld e, TOOL_TIP_LINE2
    call Print.clearLine
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
    ld hl, GS_TITLE
    call GameStateMachine.change
    ret

.lifeLine1Clicked:
    ld hl, GS_LIFELINE_TILE
    call GameStateMachine.change
    ret
.lifeLine2Clicked:
    ld hl, GS_LIFELINE_SLOT
    call GameStateMachine.change
    ret
.lifeLine3Clicked:
    ld hl, GS_LIFELINE_SOLVE
    call GameStateMachine.change
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
    ld a, 1 | SPRITE_VISIBILITY_MASK
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
    ld a, 0 | SPRITE_VISIBILITY_MASK
    ld (SpriteList.list + spriteItem.pattern),a
    ret

stateMouseDragEnd:
    ;Update mouse pointer pattern
    ld a, 0 | SPRITE_VISIBILITY_MASK
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


printQuitTip:
    ld hl, .tip
    ld e, TOOL_TIP_LINE1
    ld b,%00000000
    call Print.printCentred
    ret
.tip:   db "Drop out of college",0

printTipLifeLine1:
    ld hl, .tip1
    ld e, TOOL_TIP_LINE1
    ld b,%00000000
    call Print.printCentred
    ld hl, .tip2
    ld e, TOOL_TIP_LINE2
    ld b,%00010000
    call Print.printCentred
    ret
.tip1:   db "Match a TILE to a SLOT",0
.tip2:   db "Cost -10s",0

printTipLifeLine2:
    ld hl, .tip1
    ld e, TOOL_TIP_LINE1
    ld b,%00000000
    call Print.printCentred
    ld hl, .tip2
    ld e, TOOL_TIP_LINE2
    ld b,%00010000
    call Print.printCentred
    ret
.tip1:   db "Match a SLOT to a TILE",0
.tip2:   db "Cost -20s",0

printTipLifeLine3:
    ld hl, .tip1
    ld e, TOOL_TIP_LINE1
    ld b,%00000000
    call Print.printCentred
    ld hl, .tip2
    ld e, TOOL_TIP_LINE2
    ld b,%00010000
    call Print.printCentred
    ret
.tip1:   db "Reveal a RANDOM match",0
.tip2:   db "Cost -5s",0

printTipLifeLine4:
    ld hl, .tip1
    ld e, TOOL_TIP_LINE1
    ld b,%00000000
    call Print.printCentred
    ld hl, .tip2
    ld e, TOOL_TIP_LINE2
    ld b,%00010000
    call Print.printCentred
    ret
.tip1:   db "Reveal a CLUE",0
.tip2:   db "Cost -10s",0


nullDragEndCallback:
    ret

dragEndCallback:
    dw nullDragEndCallback

    endmodule