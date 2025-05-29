    module game

init:
    ld a,30
    call sprite.load
    ret

run:
    call mouse.update
    ld hl,(mouse.mouseX)
    ld a,(mouse.mouseY)
    ld (sprite.list + sprite.x),hl
    ld (sprite.list + sprite.y),a

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
    ld (sprite.list + sprite.pattern),a

    call sprite.updateAll

    xor a
    out 254,a
    call graphics.waitRaster
    ld a,1
    out 254,a
    jr run
    ret

spriteId:       db 0
dragId:         db 0
    endmodule