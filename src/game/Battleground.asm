;-----------------------------------------------------------------------------------
; 
; State: Battleground
; 
; Test state for trying out code
; 
;-----------------------------------------------------------------------------------

    module GameState_Battleground

@GS_BATTLEGROUND: 
    stateStruct enter,update

xPos:
    db 160
yPos:
    db 100


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a,5
    call Graphics.fillLayer2_320
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Tile.removeAll
    ld hl,titleText
    ld c, 16
    call Tile.createTiles
    call Tile.tilesToSprites

    call addButtons
    ret

update:
    ;wait for use to click mouse button
    call mouseUpdate
    cp MouseDriver.STATE_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    ld hl, GS_START
;    call GameStateMachine.change
    ret


addButtons:
    ld hl, buttonSprite
    call SpriteList.addSprite
    ld hl, bigRedButton
    call SpriteList.addSprite
    ld hl, upSprite
    call SpriteList.addSprite
    ld hl, downSprite
    call SpriteList.addSprite
    ld hl, leftSprite
    call SpriteList.addSprite
    ld hl, rightSprite
    call SpriteList.addSprite
    ret

updatePosition:

    ret


mouseUpdate:
    ; Get the latest mouse X,Y and buttons
    call MouseDriver.update
    ld hl,(MouseDriver.mouseX)
    ld a,(MouseDriver.mouseY)
    ; Store X,Y in mouse's spriteItem
    ld (SpriteList.list + spriteItem.x),hl
    ld (SpriteList.list + spriteItem.y),a
    ;A=0 no sprites
    xor a
    call MouseDriver.updateState
    ld a, (MouseDriver.state)

    call mouseStateHandler
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
stateMouseClicked:
stateMouseDragStart:
stateMouseDrag:
stateMouseDragOutOfBounds:
stateMouseDragEnd:
stateMouseClickedOff:
stateMouseBackgroundPressed:
stateMouseBackgroundClicked:
    ; Do nothing
    ret




titleText:
    db "BATTLEGROUND",0

buttonSprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 174, 50, 0, 36, 210, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

bigRedButton:
    spriteItem 0, 130, 50, 0, 37, 211, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

upSprite:
    spriteItem 0, 8, 50, 0, 28, 201, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
downSprite:
    spriteItem 0, 8, 70, 0, 11, 202, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
leftSprite:
    spriteItem 0, 8, 90, 0, 19, 203, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
rightSprite:
    spriteItem 0, 8, 110, 0, 25, 204, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

    endmodule