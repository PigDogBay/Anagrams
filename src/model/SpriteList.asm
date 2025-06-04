
;-----------------------------------------------------------------------------------
;
; Sprite attributes data struct
; Note @ overides local behaviour so clients do not need module prefix, sprite.
;
;-----------------------------------------------------------------------------------
    struct @spriteItem
id          byte
x           word
y           byte
pattern     byte    
gameId      byte
flags       byte
    ends

count:
    db 1
list:
    ;Reserve enough space for rest of sprites (Max 127)
    block spriteItem * 127
