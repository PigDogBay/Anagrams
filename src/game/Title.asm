;-----------------------------------------------------------------------------------
; 
; State: Title
; 
; Shows title screen
; 
;-----------------------------------------------------------------------------------

    module GameState_Title

@GS_TITLE: 
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

    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites
    ret

titleText:
    db "AMAZOGRAMS",0

    endmodule