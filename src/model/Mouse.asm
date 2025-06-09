    MODULE Mouse

collisionBoxSize: equ 16


;-----------------------------------------------------------------------------------
;
; addSpritePointer
;
; Note the sprite pointer must be the first sprite
; Dirty HL
;
;-----------------------------------------------------------------------------------
addSpritePointer:
    ld hl, pointerSpriteItem
    call SpriteList.addSprite
    ret
pointerSpriteItem:
    spriteItem 0,0,0,0,0,0


;-----------------------------------------------------------------------------------
;
; Function mouseOver
;
; Checks if the mouse pointer is over a sprite
;
; Returns the id of any sprite that the mouse is over
;
; Out A - sprite id, or 0 if not over any sprite
; Out IX - pointer to spriteItem if over a sprite
;
;-----------------------------------------------------------------------------------
mouseOver:
    ld a,(SpriteList.count)
    ;Skip the mouse pointer sprite
    dec a
    ;If 0 return as no collision
    ret z
    ld b,a
    ld ix, SpriteList.list
.nextSprite:
    ;Point to next sprite's data struct
    ld hl, ix
    add hl,spriteItem
    ld ix,hl

    ;Check y overlap
    ld a, (SpriteList.list+spriteItem.y)
    ld d, (ix+spriteItem.y)
    sub d
    jr c, .noCollision
    cp collisionBoxSize
    jr nc, .noCollision

    ;Check x collision
    ld hl,(SpriteList.list + spriteItem.x)
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
; Record the x,y offsets between the mouse and sprite
; Can use these offsets to prevent the sprite snapping to the mouse
; in A - sprite id to drag
;
;-----------------------------------------------------------------------------------
funcDragStart:
    ; Get spriteItem matching spriteId (A) in HL
    call SpriteList.find

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
    ld hl,(SpriteList.list + spriteItem.x)
    ;Clear carry flag
    xor a
    sbc hl,de
    ;x should be positive
    jr c, .illegalX
    ld a,l
    ld (dragXOffset),a
 
.illegalX:   
    ;Mouse y
    ld a,(SpriteList.list + spriteItem.y)
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
    call SpriteList.find
    ;check if found
    ld a,h
    or l
    jr z, .noSpriteFound

    ld ix,hl
    ld hl,(SpriteList.list + spriteItem.x)
    ld d,0
    ld a,(dragXOffset)
    ld e,a
    xor a
    sbc hl,de
    ld (ix+spriteItem.x),l
    ld (ix+spriteItem.x+1),h
    
    ld a,(dragYOffset)
    ld e,a
    ld a,(SpriteList.list + spriteItem.y)
    sub e
    ld (ix+spriteItem.y),a

.noSpriteFound
    ret

dragXOffset:
    db 0
dragYOffset:
    db 0

    endmodule
