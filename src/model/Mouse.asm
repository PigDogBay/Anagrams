    MODULE Mouse

collisionBoxSize: equ 16


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

    ;Is the sprite visible
    IS_SPRITE_VISIBLE
    jr z, .noCollision

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
; Function dragStart 
; 
; Record the x,y offsets between the mouse and sprite
; Can use these offsets to prevent the sprite snapping to the mouse
;
; In:  IX - ptr to spriteItem of the dragged sprite
;
;-----------------------------------------------------------------------------------
dragStart:
    ;Zero drag offsets
    xor a
    ld (dragXOffset),a
    ld (dragYOffset),a
    
    ;x-coord: DE
    ld e,(ix+spriteItem.x)
    ld d,(ix+spriteItem.x+1)
    ;y-coord: B
    ld b,(ix+spriteItem.y)

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
    jr c, .exit
    ld (dragYOffset),a
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function dragSprite 
; 
; Drags the sprite to the current mouse XY.
; dragX and Y offsets are applied to keep the mouse and sprite relative positions fixed
;
; In:  IX - ptr to spriteItem of the dragged sprite
;
;-----------------------------------------------------------------------------------
dragSprite:
    ld hl,(SpriteList.list + spriteItem.x)
    ; Apply drag X offset
    ld d,0
    ld a,(dragXOffset)
    ld e,a
    xor a
    sbc hl,de
    ld (ix+spriteItem.x),l
    ld (ix+spriteItem.x+1),h
    
    ; Apply drag Y offset
    ld a,(dragYOffset)
    ld e,a
    ld a,(SpriteList.list + spriteItem.y)
    sub e
    ld (ix+spriteItem.y),a

    ret

dragXOffset:
    db 0
dragYOffset:
    db 0

    endmodule
