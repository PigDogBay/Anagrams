    module game

init:
    ld a,30
    call sprite.load
    ret

run:
    call mouse.update
    ld hl,(mouse.mouseX)
    ld a,(mouse.mouseY)
    ld (sprite_data + sprite.x),hl
    ld (sprite_data + sprite.y),a

    ;Check left mouse button (bit 1, 0 - pressed)
    ld a,(mouse.buttons)
    ld b,0
    bit 1,a
    jr nz,.buttonPressed
    ld b,1
.buttonPressed
    ld a,b
    ld (sprite_data + sprite.pattern),a

    ld hl,sprite_data
    call sprite.update
    ld hl,sprite_data + sprite.size
    call sprite.update

    ld a,1
    out 254,a
    call graphics.waitRaster
    xor a
    out 254,a
    jr run
    ret

sprite_data:
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,160,0,128,0
    db 1,100,0,150,16

    endmodule