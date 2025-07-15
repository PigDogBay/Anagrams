    MODULE SpriteList

;-----------------------------------------------------------------------------------
;
; Struct: spriteItem 
;
; Sprite attributes data struct
; Note @ overides local behaviour so clients do not need module prefix
;
; id, x, y, palette, pattern, gameId, flags
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
; Function: find(uint8 gameId) -> uint16
;
; Finds sprite data
;
; In:    A - game ID
; Out:   HL - ptr to sprite's struct
;
; Dirty: HL
;-----------------------------------------------------------------------------------
find:
    push BC
    ld hl,count
    ld b,(hl)
    ; point to list
    inc hl
    add hl, spriteItem.gameId
.next
    cp (hl)
    jr z, .found
    add hl,spriteItem
    djnz .next
    ; no match found
    ld hl,0
    pop bc
    ret

.found:
    or a
    ld bc, spriteItem.gameId
    sbc hl,bc
    pop bc
    ret

;-----------------------------------------------------------------------------------
;
; Function: bringToFront
;
; Moves the Sprite in front of the other sprites (except the mouse)
; Code uses HL instead of IX for speed
; 
; In:    IX - ptr to spriteItem struct
; Out:   IX - updated ptr to the spriteItem struct
; 
; Dirty A, BC, DE, HL, IX
;
;-----------------------------------------------------------------------------------
bringToFront:
    ld hl,ix
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

    ld ix, list+spriteItem
    ret





;-----------------------------------------------------------------------------------
;
; Function: collisionCheck(uint16 ptr1, uint16 ptr2) -> bool
;
; Reserves a place in the sprite list, the sprites ID will be set and 
; the sprite count incremented
;
; In:
;       IX - ptr to sprite1
;       IY - ptr to sprite2
;       A  - Overlap (0-15)
; Out: A - 0 no collision, 1 collision
;
;-----------------------------------------------------------------------------------
collisionCheck:
    push bc
    push de
    push hl

    ld b,a
    ;Check y-co-ords first
    ld d, (ix+spriteItem.y)
    ld e, (iy+spriteItem.y)
    call Maths.difference
    cp b
    ld a,0
    jr nc, .exit

    ;Check x-coords
    ld hl,(ix + spriteItem.x)
    ;Little endian, LSB into e, then MSB into d
    ld e,(iy+spriteItem.x)
    ld d,(iy+spriteItem.x+1)
    call Maths.difference16
    ld d,0
    ld e,b
    xor a
    sbc hl,de
    jr nc, .exit

    ;Collided
    ld a,1

.exit:
    pop hl
    pop de
    pop bc
    ret




;-----------------------------------------------------------------------------------
;
; Function: removeAllInteraction()
;
; Clears interaction flags (hover, clickable, draggable) on all sprites
; The function will temporarily save the flags in bits 7-4 of the flags field
;
;-----------------------------------------------------------------------------------
removeAllInteraction:
    push bc,de,hl
    ld a,(count)
    ld b,a
    ;Point to first sprite, will immediately skip mouse sprite
    ld hl, list
.loop:
    add hl, spriteItem
    ld de,hl
    add hl, spriteItem.flags
    ld a,(hl)
    ;store the interaction bits 3-0 in unused bits 7-4
    sla a: sla a: sla a: sla a
    ld (hl),a
    ex de,hl
    djnz .loop

    pop hl,de,bc
    ret


;-----------------------------------------------------------------------------------
;
; Function: restoreAllInteraction()
;
; Restores interaction flags, must have called removeAllInteraction() previously
; as this will store the flags in bits 7-4
;
;-----------------------------------------------------------------------------------
restoreAllInteraction:
    push bc,de,hl
    ld a,(count)
    ld b,a
    ;Point to first sprite, will immediately skip mouse sprite
    ld hl, list
.loop:
    add hl, spriteItem
    ld de,hl
    add hl, spriteItem.flags
    ld a,(hl)
    ;Restore the interaction bits 3-0 in from bits 7-4
    sra a: sra a: sra a: sra a
    ld (hl),a
    ex de,hl
    djnz .loop

    pop hl,de,bc
    ret

;-----------------------------------------------------------------------------------
;
; Function: allTilesClickable()
;
; Sets the clickable+hoverable interaction flags for all tile sprites
;
;-----------------------------------------------------------------------------------
allTilesClickable:
    push bc,de,ix
    ld a,(count)
    ld b,a
    ;Point to first sprite, will immediately skip mouse sprite
    ld ix, list
    ld de, spriteItem
.loop:
    ld a,(ix+spriteItem.gameId)
    and GameId.TILE_ID
    jr z, .skip
    ;Sprite is a tile
    ;Keep stored flags, clear mouse interaction flags
    ld a,(ix+spriteItem.flags)
    and %11110000
    ;Make clickable and hoverable
    or MouseDriver.MASK_HOVERABLE|MouseDriver.MASK_CLICKABLE
    ld (ix+spriteItem.flags),a
.skip:
    add ix,de
    djnz .loop

    pop ix,de,bc
    ret

;-----------------------------------------------------------------------------------
;
; Function: allTilesClickable()
;
; Sets the clickable+hoverable interaction flags for all slot sprites
;
;-----------------------------------------------------------------------------------
allSlotsClickable:
    push bc,de,ix
    ld a,(count)
    ld b,a
    ;Point to first sprite, will immediately skip mouse sprite
    ld ix, list
    ld de, spriteItem
.loop:
    ld a,(ix+spriteItem.gameId)
    and GameId.SLOT_ID
    jr z, .skip
    ;Sprite is a tile
    ;Keep stored flags, clear mouse interaction flags
    ld a,(ix+spriteItem.flags)
    and %11110000
    ;Make clickable and hoverable
    or MouseDriver.MASK_HOVERABLE|MouseDriver.MASK_CLICKABLE
    ld (ix+spriteItem.flags),a
.skip:
    add ix,de
    djnz .loop

    pop ix,de,bc
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
