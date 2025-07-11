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

    ld hl,$0101
    call Puzzles.select

    ld ix,timer1
    ld hl,100
    call Timing.startTimer

    ret



update:
    call mouseUpdate
    call Game.updateSprites

    ld ix,timer1
    call Timing.hasTimerElapsed
    or a
    ret z
    call Timing.restartTimer
    call Tilemap.clear
    call printRound
    ret


printRound:

    call Puzzles.getCategory
    call Puzzles.categoryToString
    ld d, 5
    ld e, 9
    call Print.setCursorPosition
    call Print.printString

    call Puzzles.getAnagram
    ld d, 5
    ld e, 10
    call Print.setCursorPosition
    call Print.printString

    call Puzzles.jumbleLetters
    ld d, 5
    ld e, 11
    call Print.setCursorPosition
    call Print.printString

    call Puzzles.getClue
    ld d, 5
    ld e, 12
    call Print.setCursorPosition
    call Print.printString
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

timer1:
    timingStruct 0,0,0


    endmodule