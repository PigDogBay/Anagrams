    MODULE SpriteList

;-----------------------------------------------------------------------------------
;
; Struct: spriteItem 
;
; Sprite attributes data struct
; Note @ overides local behaviour so clients do not need module prefix
;
;-----------------------------------------------------------------------------------
    struct @spriteItem
id          byte
x           word
y           byte
palette     byte
pattern     byte    
gameId      byte
flags       byte
    ends

;-----------------------------------------------------------------------------------
;
; Function: addSprite
;
; Copies spriteItem data to the list, increases the count.
; Note that the SpriteID will be assigned here
; In:
;       HL - Pointer to Sprite Item struct to add
;
; Note all registers are restored
;
;-----------------------------------------------------------------------------------
addSprite:
    push af : push bc : push de : push hl

    ;First set the sprite ID
    ld a, (nextSpriteId)
    ld (hl),a
    ;Increase the next sprite ID by 1 for next time
    inc a
    ld (nextSpriteId),a

    ; Increase count by 1
    ld a,(count)
    inc a
    ld (count),a

    ; Set up number of bytes to copy
    ld b,0
    ld c,spriteItem

    ld de,(nextEntryPtr)
    ldir
    ; DE now points to the next empty entry in the list
    ld (nextEntryPtr),de

    pop hl : pop de : pop bc : pop af
    ret

;-----------------------------------------------------------------------------------
;
; Function: reserveSprite
;
; Reserves a place in the sprite list, the sprites ID will be set and 
; the sprite count incremented
;
; Out:
;       IX - Pointer to a new reserved Sprite Item struct
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
reserveSprite:
    push hl
    ld hl,(nextEntryPtr)

    ; Increase count by 1
    ld a,(count)
    inc a
    ld (count),a

    ;Set the sprite ID
    ld a,(nextSpriteId)
    ld (hl),a
    ;Increase the next sprite ID by 1 for next time
    inc a
    ld (nextSpriteId),a
    ld ix,hl
    ; update the next entry pointer
    add hl, spriteItem
    ld (nextEntryPtr),hl
    pop hl
    ret


;-----------------------------------------------------------------------------------
;
; Function: removeAll
;
; Resets counter and next sprite ID to 0
;
; Dirty A
;-----------------------------------------------------------------------------------
removeAll:
    xor a
    ld (nextSpriteId),a
    ld (count),a
    ; Point to the start of the list
    ld hl,list
    ld (nextEntryPtr),hl
    ret



;-----------------------------------------------------------------------------------
;
; Function: find
;
; Finds sprite data
;
; In:    A - id
; Out:   HL - ptr to sprite's struct
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

;-----------------------------------------------------------------------------------
;
; Function: bringToFront
;
; Moves the Sprite in front of the other sprites (except the mouse)
; Code uses HL instead of IX for speed
; 
; In:    HL - ptr to spriteItem struct
; Out:   HL - updated ptr to the spriteItem struct
; 
; Dirty A, BC, DE
;
;-----------------------------------------------------------------------------------
bringToFront:
    ; Point to entry for sprite ID 1
    ld de,list+spriteItem
    ;Skip ID, just swap other data
    ld b, spriteItem - 1
.next:
    inc de
    inc hl
    ld a,(de)
    ld c,(hl)
    ld (hl),a
    ld a,c
    ld (de),a
    djnz .next

    ld hl, list+spriteItem
    ret

nextEntryPtr:
    dw list
nextSpriteId:
    db 0

count:
    db 0
list:
    ;Reserve enough space for rest of sprites (Max 128)
    block spriteItem * 128

    endmodule
