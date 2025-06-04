    module game

init:
    ld a,30
    call NextSprite.load
    ld hl,anagram
    ld ix,SpriteList.list+spriteItem
    call Tile.wordToSprites
    ret

run:
    call MouseDriver.update
    ld hl,(MouseDriver.mouseX)
    ld a,(MouseDriver.mouseY)
    ld (SpriteList.list + spriteItem.x),hl
    ld (SpriteList.list + spriteItem.y),a

    call Mouse.mouseOver
    ld (spriteId),a
    
    call MouseDriver.updateState
    ld a, (MouseDriver.state)
    cp MouseDriver.STATE_DRAG_START
    jr nz, .checkDrag
    ld a,(spriteId)
    ld (dragId),a
    call Mouse.funcDragStart
    jr .doneDrag

.checkDrag
    ld a, (MouseDriver.state)
    cp MouseDriver.STATE_DRAG
    jr nz,.noDrag

    ld a, (dragId)
    call Mouse.funcDrag

.noDrag:    
    ld a,(spriteId)
.doneDrag:

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

spriteId:       db 0
dragId:         db 0

anagram:
    db "ACORNELECTRON",0
    endmodule