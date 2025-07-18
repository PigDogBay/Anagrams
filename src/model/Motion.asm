;-----------------------------------------------------------------------------------
; 
; Animation: Motion
; 
; Helper functions for moving sprites
; 
;-----------------------------------------------------------------------------------

    module Motion
    
    struct @motionStruct
gameId      byte
stepX       word
countX      word
stepY       byte
countY      byte
delay       byte
    ends


;-----------------------------------------------------------------------------------
;
; Function: init(uint16 motion)
;
; Initializes the motionStruct's fields
;
; In IX: pointer to motionStruct
;        motionStruct.stepX = destination X
;        motionStruct.stepY = destination Y
;
;-----------------------------------------------------------------------------------
init:
    ret


;-----------------------------------------------------------------------------------
;
; Function: isStillMoving(uint16 motion)
;
; Checks if the motion has finished
;
; In IX: pointer to motionStruct
;
; Out: Z = false (finished), NZ = true, still moving
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
isStillMoving:
    ld a,(ix + motionStruct.countY)
    or a
    jr nz, .exit

    ld a,(ix + motionStruct.countX)
    or (ix + motionStruct.countX+1)

.exit
    ret

;-----------------------------------------------------------------------------------
;
; Function: updateX(uint16 motion, uint16 sprite)
;
; Updates the X co-ordinate of the sprite
;
; In IX: pointer to motionStruct
;    IY: pointer to spriteItem
;
;-----------------------------------------------------------------------------------
updateX:
    ld l,(ix + motionStruct.countX)
    ld h,(ix + motionStruct.countX+1)
    ld a,h
    or l
    ret z

    dec hl
    ld (ix + motionStruct.countX),l
    ld (ix + motionStruct.countX+1),h

    ld e,(iy+spriteItem.x)
    ld d,(iy+spriteItem.x+1)
    ld l,(ix + motionStruct.stepX)
    ld h,(ix + motionStruct.stepX+1)
    add hl,de
    ld (iy+spriteItem.x),l
    ld (iy+spriteItem.x+1),h
    ret


;-----------------------------------------------------------------------------------
;
; Function: updateY(uint16 motion, uint16 sprite)
;
; Updates the Y co-ordinate of the sprite
;
; In IX: pointer to motionStruct
;    IY: pointer to spriteItem
;
;-----------------------------------------------------------------------------------
updateY:
    ld a,(ix + motionStruct.countY)
    or a
    ret z

    dec a
    ld (ix + motionStruct.countY),a

    ld l,(iy+spriteItem.y)
    ld a,(ix + motionStruct.stepY)
    add a,l
    ld (iy+spriteItem.y),a
    ret

    endmodule