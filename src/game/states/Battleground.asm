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

    call addButtons

    ld ix,timer1
    ld hl,50
    call Timing.startTimer

    ld a,5
    call Motion.start

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


update:
    call mouseUpdate
    call Game.updateSprites
    call Animator.update

    ; ld ix,timer1
    ; call Timing.hasTimerElapsed
    ; ret z
    ; call Timing.restartTimer
    ; call Tilemap.clear
    ; call printRound
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
    ld a,c
    cp BUTTON_FLASH_ID
    jr z, .flashClicked
    cp BUTTON_FLASHTWO_ID
    jr z, .flashTwoClicked
    cp BUTTON_FLASH_SPRITES_ID
    jr z, .flashSpritesClicked
    ret
.flashClicked:
    ld a,5
    call Flash.start
    ret

.flashTwoClicked:
    ld a,5
    ld b,6
    ld c,100
    call FlashTwo.start
    ret
.flashSpritesClicked:
    ld hl, FlashSprites.idList
    ld (hl),5
    inc hl
    ld (hl),6

    inc hl
    ld (hl),1
    inc hl
    ld (hl),2
    inc hl
    ld (hl),3
    inc hl
    ld (hl),4
    inc hl
    ld (hl),0

    ld hl,100
    call FlashSprites.start
    ret


titleText:
    db "BATTLEGROUND",0

timer1:
    timingStruct 0,0,0

BUTTON_FLASH_ID: equ 1 
BUTTON_FLASHTWO_ID: equ 2
BUTTON_FLASH_SPRITES_ID: equ 3
BUTTON_RIGHT_ID: equ 4
SPACESHIP_ID: equ 5

spaceShipSprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 300, 220, 0, 36, 5, 0

bigRedButton:
    spriteItem 0, 130, 50, 0, 37, 6, 0

upSprite:
    spriteItem 0, 8, 50, 0, 13, BUTTON_FLASH_ID, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
downSprite:
    spriteItem 0, 8, 70, 0, 11, BUTTON_FLASHTWO_ID, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
leftSprite:
    spriteItem 0, 8, 90, 0, 19, BUTTON_FLASH_SPRITES_ID, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
rightSprite:
    spriteItem 0, 8, 110, 0, 25, 4, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

    endmodule