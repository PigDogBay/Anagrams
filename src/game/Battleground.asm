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
    dw 174
yPos:
    db 50


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a,5
    call Graphics.fillLayer2_320
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call GameId.reset
    call Tile.removeAll
    ld hl,titleText
    call Tile.createTiles
    call Tile.tilesToSprites

    call addButtons
    ret

update:
    call mouseUpdate
    call updatePosition
    call Game.updateSprites
    ret



addButtons:
    ld hl, spaceShipSprite
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
    ld a, SPACESHIP_ID
    call SpriteList.find
    ld ix,hl
    ld a, (yPos)
    ld (ix+spriteItem.y),a
    ld hl,(xPos)
    ld (ix+spriteItem.x),hl
    ret


mouseUpdate:
    ; Get the latest mouse X,Y and buttons
    call MouseDriver.update
    ld hl,(MouseDriver.mouseX)
    ld a,(MouseDriver.mouseY)
    ; Store X,Y in mouse's spriteItem
    ld (SpriteList.list + spriteItem.x),hl
    ld (SpriteList.list + spriteItem.y),a

    ;Check if the pointer is over a sprite
    ; A - sprite ID and IX - spriteItem if over a sprite
    ; A = 0 not over a sprite
    call Mouse.mouseOver

    ; Update the mouse pointer state
    ; In A - interaction flags, or 0 if not over a sprite
    ; In C - gameId or 0
    ld c,a
    or a
    jr z, .noSpriteOver
    ld a,(ix+spriteItem.flags)
    ld c,(ix+spriteItem.gameId)
.noSpriteOver:    
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
stateMouseDragStart:
stateMouseDrag:
stateMouseDragOutOfBounds:
stateMouseDragEnd:
stateMouseClickedOff:
stateMouseBackgroundPressed:
stateMouseBackgroundClicked:
    ; Do nothing
    ret

stateMouseClicked:
    //TODO, C = Sprites GameID
    //Write Button pressed event

    ld a,c
    cp BUTTON_UP_ID
    jr z, .upClicked

    cp BUTTON_DOWN_ID
    jr z, .downClicked

    cp BUTTON_LEFT_ID
    jr z, .leftClicked

    cp BUTTON_RIGHT_ID
    jr z, .rightClicked
    ret

.upClicked:
    ld a,(yPos)
    dec a
    ld (yPos),a
    ret
.downClicked:
    ld a,(yPos)
    inc a
    ld (yPos),a
    ret
.leftClicked:
    ld hl,(xPos)
    dec hl
    ld (xPos),hl
    ret
.rightClicked:
    ld hl,(xPos)
    inc hl
    ld (xPos),hl
    ret



titleText:
    db "BATTLEGROUND",0


BUTTON_UP_ID: equ 1 
BUTTON_DOWN_ID: equ 2
BUTTON_LEFT_ID: equ 3
BUTTON_RIGHT_ID: equ 4
SPACESHIP_ID: equ 5

spaceShipSprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 174, 50, 0, 36, 5, 0

bigRedButton:
    spriteItem 0, 130, 50, 0, 37, 6, 0

upSprite:
    spriteItem 0, 8, 50, 0, 28, 1, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
downSprite:
    spriteItem 0, 8, 70, 0, 11, 2, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
leftSprite:
    spriteItem 0, 8, 90, 0, 19, 3, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
rightSprite:
    spriteItem 0, 8, 110, 0, 25, 4, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

    endmodule