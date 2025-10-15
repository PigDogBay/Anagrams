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
HINTS_DISABLE_COUNT equ 250

TOOLTIP_COLOUR1     equ Tilemap.WHITE
TOOLTIP_COLOUR2     equ Tilemap.RED
       
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
; In -  A : current mouse state
;    -  C : Game ID or 0 if mouse not over a sprite
;    - IX : pointer to sprite that mouse is over
;-----------------------------------------------------------------------------------
update:
    ld h,a ; Save A
    call SpriteList.resetAllPaletteOffsets
    ;Hints count update
    ld a,(disableHintsCount)
    or a
    jr z, .continue
    ;Tick count down
    dec a
    ld (disableHintsCount),a

.continue:
    ld a,h ; Restore A
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
    ld (ix + spriteItem.palette),Sprites.PALETTE_HOVER
    ;Are tips enabled
    ld a,(disableHintsCount)
    or a
    ret nz

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
    ld (ix + spriteItem.palette),Sprites.PALETTE_CLICKED
    ld e, TOOL_TIP_LINE1
    call Print.clearLine
    ld e, TOOL_TIP_LINE2
    call Print.clearLine
    ret
stateMouseClicked:
    ;Temporarily disable hints
    ld a,HINTS_DISABLE_COUNT
    ld (disableHintsCount),a

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
    call Sound.buttonClicked
    ld hl, GS_TITLE
    call GameStateMachine.change
    ret

.lifeLine1Clicked:
    call Sound.buttonClicked
    ld hl, GS_LIFELINE_TILE
    call GameStateMachine.change
    ret
.lifeLine2Clicked:
    call Sound.buttonClicked
    ld hl, GS_LIFELINE_SLOT
    call GameStateMachine.change
    ret
.lifeLine3Clicked:
    call Sound.buttonClicked
    ld hl, GS_LIFELINE_SOLVE
    call GameStateMachine.change
    ret
.lifeLine4Clicked:
    call Sound.buttonClicked
    ld hl, GS_LIFELINE_CLUE
    call GameStateMachine.change
    ret


stateMouseDragStart:
    ld (ix + spriteItem.palette),Sprites.PALETTE_DRAGGED
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
    ld (ix + spriteItem.palette),Sprites.PALETTE_DRAGGED
    call Mouse.dragSprite
    call Tile.boundsCheck
    ret nz
    ; Tile was out of bounds
    ; Need to tell mouse state machine
    call MouseDriver.dragOutOfBounds
    ret

stateMouseDragOutOfBounds:
    ;Recover sprite of what the mouse was previously hovering over
    ;It's SpriteList[1]
    ld ix,SpriteList.list+spriteItem
    ld (ix + spriteItem.palette),Sprites.PALETTE_ERROR
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
    ld b,TOOLTIP_COLOUR1
    call Print.printCentred
    ret
.tip:   db "DROP OUT OF COLLEGE",0

printTipLifeLine1:
    ld hl, Lifelines.tip1
    ld e, TOOL_TIP_LINE1
    ld b,TOOLTIP_COLOUR1
    call Print.printCentred

    ld a,(Lifelines.costTile)
    ld de, Print.buffer
    ld hl, costPrefix
    call Lifelines.printCost
    ld hl, Print.buffer
    ld e, TOOL_TIP_LINE2
    ld b,TOOLTIP_COLOUR2
    call Print.printCentred
    ret

printTipLifeLine2:
    ld hl, Lifelines.tip2
    ld e, TOOL_TIP_LINE1
    ld b,TOOLTIP_COLOUR1
    call Print.printCentred

    ld a,(Lifelines.costSlot)
    ld de, Print.buffer
    ld hl, costPrefix
    call Lifelines.printCost
    ld hl, Print.buffer
    ld e, TOOL_TIP_LINE2
    ld b,TOOLTIP_COLOUR2
    call Print.printCentred
    ret

printTipLifeLine3:
    ld hl, Lifelines.tip3
    ld e, TOOL_TIP_LINE1
    ld b,TOOLTIP_COLOUR1
    call Print.printCentred

    ld a,(Lifelines.costRand)
    ld de, Print.buffer
    ld hl, costPrefix
    call Lifelines.printCost
    ld hl, Print.buffer
    ld e, TOOL_TIP_LINE2
    ld b,TOOLTIP_COLOUR2
    call Print.printCentred
    ret

printTipLifeLine4:
    ld hl, Lifelines.tip4
    ld e, TOOL_TIP_LINE1
    ld b,TOOLTIP_COLOUR1
    call Print.printCentred

    ld a,(Lifelines.costClue)
    ld de, Print.buffer
    ld hl, costPrefix
    call Lifelines.printCost
    ld hl, Print.buffer
    ld e, TOOL_TIP_LINE2
    ld b,TOOLTIP_COLOUR2
    call Print.printCentred
    ret

nullDragEndCallback:
    ret

dragEndCallback:
    dw nullDragEndCallback

disableHintsCount:
    db 0

costPrefix:   db "COST -",0

    endmodule