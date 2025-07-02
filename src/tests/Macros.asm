    MACRO COPY_DATA len, src
        ld bc, len
        ld de, SpriteList.count
        ld hl, src
        ldir
    ENDM

    MACRO WRITE_BYTE addr, value
        ld a,value
        ld (addr),a
    ENDM

    MACRO WRITE_WORD addr, value
        push hl
        ld hl,value
        ld (addr),hl
        pop hl
    ENDM