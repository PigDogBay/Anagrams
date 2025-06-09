    module game

init:
    ld a,30
    call NextSprite.load
    call SpriteList.removeAll
    call Mouse.addSpritePointer
    ld hl,anagram
    call Tile.wordToSprites
    ret

run:
    call updateMouse
    

    ;Check left mouse button (bit 1, 0 - pressed)
    ld a,(MouseDriver.buttons)
    ld b,0
    bit 1,a
    jr nz,.buttonPressed
    ld b,1
.buttonPressed
    ld a,b
    ld (SpriteList.list + spriteItem.pattern),a

    ld hl, SpriteList.count
    ld b,(hl)
    inc hl
.updateSprites:
    call NextSprite.update
    djnz .updateSprites

    BORDER 0
    call graphics.waitRaster
    ; Set border to blue, size of border indicates how much time is spent updating the game
    BORDER 1
    jr run
    ret


;-----------------------------------------------------------------------------------
;
; Function updateMouse
;
;
;
;
;-----------------------------------------------------------------------------------
updateMouse:
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
    ; Store A for later use, IX is kept clean
    ld (spriteId),a

    ; Update the mouse pointer state
    ; In A - spriteID or 0 if not over a sprite
    call MouseDriver.updateState

    ; Check latest mouse state
    ld a, (MouseDriver.state)
    cp MouseDriver.STATE_DRAG_START
    jr nz, .checkDrag

    ; DRAG_START
    ; Store spriteItem ptr (from mouseOver)
    ld (dragSpriteItem),ix
    call Mouse.dragStart
    jr .exit

.checkDrag
    cp MouseDriver.STATE_DRAG
    jr nz,.exit

    ; DRAG update, in IX - ptr to spriteItem of dragged sprite
    ld ix,(dragSpriteItem)
    call Mouse.dragSprite

.exit:
    ret

spriteId:               db 0
dragSpriteItem:         dw 0

anagram:
    db "ACORNELECTRON",0
    endmodule