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

    ld a,1
    out 254,a
    call graphics.waitRaster
    xor a
    out 254,a
    jr run
    ret

    endmodule