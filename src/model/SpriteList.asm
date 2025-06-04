    MODULE SpriteList

;-----------------------------------------------------------------------------------
;
; Sprite attributes data struct
; Note @ overides local behaviour so clients do not need module prefix
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

;-----------------------------------------------------------------------------------
;
; Find sprite data
; In A - id
; Out HL - ptr to sprite's struct
;-----------------------------------------------------------------------------------
find:
    ld hl,count
    ld b,(hl)
    ; point to list
    inc hl
.next
    cp (hl)
    ret z
    add hl,spriteItem
    djnz .next
    ; no match found
    ld hl,0
    ret

count:
    db 1
list:
    ;Reserve enough space for rest of sprites (Max 127)
    block spriteItem * 127

    endmodule
