    MODULE sprite

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
    ends

collisionBoxSize: equ 16


;-----------------------------------------------------------------------------------
;
; Load sprite data from banks
;
; Disable interrupts before calling this function
; Load 2 memory consequetive 8k banks into sprite memory
; Parameters:
; bank = First bank, next bank is bank+1 (Set in A register)
;
;-----------------------------------------------------------------------------------
load:
    ; swap out ROM with bank, bank+1
    nextreg MMU_0,a 
    inc a 
    nextreg MMU_1,a

    ; Set first sprite pattern slot to 0
    xor a
    ld bc, SPRITE_STATUS_SLOT_SELECT
    out (c), a

    ; Sprite data starts at 0x0000
    ld hl,0
    ; Copy 64 sprite patterns to sprite memory
    ld a,64
next_pattern:
        ; b is set to 0 (256 bytes), c is set to the pattern upload port address
        ld bc, SPRITE_PATTERN_UPLOAD_256
        ; Send data to sprite memory port, HL and sprite pattern will automatically increment
        otir
        dec a
        jr nz, next_pattern

    ; Restore ROM
    nextreg $50, $FF
    nextreg $51, $FF
    ret

;-----------------------------------------------------------------------------------
; 
; Update sprite
;
; in HL = pointer to sprite data structure
; out HL = next sprite in the list
; dirty a,d
;
;-----------------------------------------------------------------------------------
update:
    ;preserve bc
    push bc
    ; Set sprite id for attribute upload
    ld bc, SPRITE_STATUS_SLOT_SELECT
    ld a,(hl)
    out (c), a

    ld bc, SPRITE_ATTRIBUTE_UPLOAD

    ; Byte 1
    ; X position (Low 8 bits)
    inc hl
    ld a,(hl)
    out (c),a

    ; X position bit 9
    inc hl
    ld a,(hl)
    and 1

    ; Byte 2
    ; Y position (Low 8 bits)
    inc hl
    ld d,(hl)
    out (c),d

    ; Byte 3
    ; Bit 0 - MSB of X position
    out (c),a

    ; Byte 4
    ; Bit 7 - Visibility
    ; Bit 6 - 0, don't need 5th byte for scaling
    ; Bit 5-0 - Pattern index
    inc hl
    ld a,(hl)
    ; enable visibility bit 7
    or $80
    out (c),a
    ; Byte 5, not used here
    ;point to the next sprite in the list
    inc hl
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Remove sprite
; Sets all attributes to zero and sprite invisibile
; In: A = Sprite ID
; 
;-----------------------------------------------------------------------------------
remove:
    ;preserve bc
    push bc
    ; Set sprite id for attribute upload
    ld bc, SPRITE_STATUS_SLOT_SELECT
    out (c), a

    ld bc, SPRITE_ATTRIBUTE_UPLOAD

    ; Byte 1
    ; X position (Low 8 bits)
    xor a
    out (c),a

    ; Byte 2
    ; Y position (Low 8 bits)
    out (c),a

    ; Byte 3
    ; Bit 0 - MSB of X position
    out (c),a

    ; Byte 4
    ; Bit 7 - 0 Invisible
    ; Bit 6 - 0 No 5th byte for scaling
    ; Bit 5 - 0 Pattern index
    out (c),a
    ; Byte 5, not used here

    ; Recover BC
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Remove all sprites
;
;-----------------------------------------------------------------------------------
removeAll:
    ld b,127
.loop:
    ; Remove sprites 1-127
    ld a,b
    call sprite.remove
    djnz .loop
    ; Remove 0 sprite
    xor a
    call sprite.remove
    ret


;-----------------------------------------------------------------------------------
; 
; Update all sprites 
; 
; Dirty a,bc,d,hl
;
;-----------------------------------------------------------------------------------
updateAll:
    ld hl,count
    ld b,(hl)
    ;point to list
    inc hl
.loop:
    call update
    djnz .loop
    ret

inRange:
    ld a,42
    ld b,54
    sub b
    jr nc, .noNeg
.noNeg
    cp 17
    

;-----------------------------------------------------------------------------------
;
; Checks if the mouse pointer is over a sprite
;
; Returns the id of any sprite that the mouse is over
; out a - sprite id, or 0 if not over any sprite
;
;-----------------------------------------------------------------------------------
mouseOver:
    ld a,(count)
    ;Skip the mouse pointer sprite
    dec a
    ;If 0 return as no collision
    ret z
    ld b,a
    ld ix, list
.nextSprite:
    ;Point to next sprite's data struct
    ld hl, ix
    add hl,spriteItem
    ld ix,hl

    ;Check y overlap
    ld a, (list+spriteItem.y)
    ld d, (ix+spriteItem.y)
    sub d
    jr c, .noCollision
    cp collisionBoxSize
    jr nc, .noCollision

    ;Check x collision
    ld hl,(list + spriteItem.x)
    ;Little endian, LSB into e, then MSB into d
    ld e,(ix+spriteItem.x)
    ld d,(ix+spriteItem.x+1)
    ;Clear carry flag
    xor a
    sbc hl,de
    jr c, .noCollision

    ;HL = +ve x-delta
    ;Check if H is zero
    xor a
    or h
    ;If not zero, then delta is > 255 - no collision
    jr nz,.noCollision
    ; check L < collisionBoxSize
    ld a,l
    cp collisionBoxSize
    jr nc, .noCollision

    ; Collision made, return sprite id
    ld a,(ix+spriteItem.id)
    ret

.noCollision:
    djnz .nextSprite
    
    ; no match, return 0
    xor a
    ret
;-----------------------------------------------------------------------------------
;
; Find sprite data
; In A - id
; Out HL - ptr to sprite's struct
;-----------------------------------------------------------------------------------
funcFind:
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
; Record the x,y offsets between the mouse and sprite
; Can use these offsets to prevent the sprite snapping to the mouse
; in A - sprite id to drag
;
;-----------------------------------------------------------------------------------
funcDragStart:
    call funcFind

    ;Zero drag offsets
    xor a
    ld (dragXOffset),a
    ld (dragYOffset),a
    
    ;check HL is not zero, should be pointing to the matching sprite struct
    ld a,h
    or l
    jr z, .noSpriteFound

    add hl,spriteItem.x
    ;x-coord
    ld de,(hl)
    inc hl
    inc hl
    ;y-coord
    ld b,(hl)

    ;Mouse x    
    ld hl,(list + spriteItem.x)
    ;Clear carry flag
    xor a
    sbc hl,de
    ;x should be positive
    jr c, .illegalX
    ld a,l
    ld (dragXOffset),a
 
.illegalX:   
    ;Mouse y
    ld a,(list + spriteItem.y)
    sub b
    ;y should be positive
    jr c, .noSpriteFound
    ld (dragYOffset),a

.noSpriteFound
    ret

;-----------------------------------------------------------------------------------
;
; Sprite Drag
; in A - sprite id to drag
;
;-----------------------------------------------------------------------------------
funcDrag:
    call funcFind
    ;check if found
    ld a,h
    or l
    jr z, .noSpriteFound

    ld ix,hl
    ld hl,(list + spriteItem.x)
    ld d,0
    ld a,(dragXOffset)
    ld e,a
    xor a
    sbc hl,de
    ld (ix+spriteItem.x),l
    ld (ix+spriteItem.x+1),h
    
    ld a,(dragYOffset)
    ld e,a
    ld a,(list + spriteItem.y)
    sub e
    ld (ix+spriteItem.y),a

.noSpriteFound
    ret

dragXOffset:
    db 0
dragYOffset:
    db 0
count:
    db 1
list:
    ;Reserve enough space for rest of sprites (Max 127)
    block spriteItem * 127


    endmodule
