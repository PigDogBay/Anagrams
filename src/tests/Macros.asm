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