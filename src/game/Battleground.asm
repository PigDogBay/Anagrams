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
    call Game.updateMouseNoSprite
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
    ret


titleText:
    db "BATTLEGROUND",0

buttonSprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 174, 50, 0, 36, 200, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

bigRedButton:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0, 130, 50, 0, 37, 201, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

    endmodule