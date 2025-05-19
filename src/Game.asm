    module game

init:
    ld a,30
    call sprite.load
    ret

run:
    call mouse.update
    ld hl,(mouse.mouseX)
    ld a,(mouse.mouseY)
    ld (sprite_data + sprite.STRUCT_SPR_X),hl
    ld (sprite_data + sprite.STRUCT_SPR_Y),a

    ld hl,sprite_data
    call sprite.update
    ld hl,sprite_data + sprite.STRUCT_SPR_SIZE
    call sprite.update

    jr run
    ret

sprite_data:
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,160,0,128,0
    db 1,100,0,150,16

    endmodule