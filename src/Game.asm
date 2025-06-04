    module game

init:
    ld a,30
    call sprite.load
    ld hl,anagram
    ld ix,sprite.list+spriteItem
    call Tile.wordToSprites
    ret

run:
    call mouse.update
    ld hl,(mouse.mouseX)
    ld a,(mouse.mouseY)
    ld (sprite.list + spriteItem.x),hl
    ld (sprite.list + spriteItem.y),a

    call sprite.mouseOver
    ld (spriteId),a
    
    call mouse.updateState
    ld a, (mouse.state)
    cp mouse.STATE_DRAG_START
    jr nz, .checkDrag
    ld a,(spriteId)
    ld (dragId),a
    call sprite.funcDragStart
    jr .doneDrag

.checkDrag
    ld a, (mouse.state)
    cp mouse.STATE_DRAG
    jr nz,.noDrag

    ld a, (dragId)
    call sprite.funcDrag

.noDrag:    
    ld a,(spriteId)
.doneDrag:

    ;Check left mouse button (bit 1, 0 - pressed)
    ld a,(mouse.buttons)
    ld b,0
    bit 1,a
    jr nz,.buttonPressed
    ld b,1
.buttonPressed
    ld a,b
    ld (sprite.list + spriteItem.pattern),a

    ld hl, sprite.count
    ld b,(hl)
    inc hl
.updateSprites:
    call sprite.update
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