    MACRO COPY_DATA len, src
        ld bc, len
        ld de, SpriteList.count
        ld hl, src
        ldir
    ENDM
