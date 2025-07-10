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


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a,7
    call Graphics.fillLayer2_320
    ; call Graphics.layer2Test320
    ; call Graphics.titleScreen
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call GameId.reset
    call Tile.removeAll
;    ld hl,titleText
;    call Tile.createTiles
;    call Tile.tilesToSprites

    call Tilemap.init
    call Tilemap.clear

    ld hl,charry
    ld d, 0
    ld e, 0
    call Print.setCursorPosition
    call Print.printString

    ld d, 39
    ld e, 0
    call Print.setCursorPosition
    call Print.printString

    ld d, 0
    ld e, 31
    call Print.setCursorPosition
    call Print.printString

    ld d, 39
    ld e, 31
    call Print.setCursorPosition
    call Print.printString

    ld hl, stringy
    ld d, 13
    ld e, 15
    call Print.setCursorPosition
    call Print.printString

    ret
charry:
    db "X",0
stringy:
    db "The Ace of Spades!",0
blah:
    db "the quick brown fox jumped over the lazy dog",0




update:
    call mouseUpdate
    call Game.updateSprites

    
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
    ret



titleText:
    db "BATTLEGROUND",0



    endmodule