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
; Function: initMoveToXY(uint16 motion)
;
; Initializes the motionStruct's fields, ensure the following fields are first set:
;       motionStruct.stepX (only works for 1)
;       motionStruct.stepY
;       motionStruct.delay
;    and
;       motionStruct.countX = destination X
;       motionStruct.countY = destination Y
;
; The countX and countY fields will be calculated as:
;       count = (dest-start)/step
;
; In IX: pointer to motionStruct
;        motionStruct.countX = destination X
;        motionStruct.countY = destination Y
;    IY: pointer to spriteItem
;
;-----------------------------------------------------------------------------------
initMoveToXY:
    ;Copy gameId
    ld a,(iy+spriteItem.gameId)
    ld (ix+motionStruct.gameId),a

    ;Count Y calculation
    ld d,(iy+spriteItem.y)
    ld e,(ix+motionStruct.countY)
    ;Returns difference in A
    call Maths.difference
    ; Divide difference by step to get count
    ld b,(ix+motionStruct.stepY)
    ;Returns quotient in C
    call Maths.divMod
    ld (ix+motionStruct.countY),c

    ;Negate step if destination < start
    ;d = start, e = dest, c = step
    ld a, d
    cp e
    jr c, .noNeg
    jr z, .noNeg
    ld a,(ix+motionStruct.stepY)
    neg
    ld (ix+motionStruct.stepY),a

.noNeg:

    ;Count X calculation (16 bit)
    ld l,(iy+spriteItem.x)
    ld h,(iy+spriteItem.x+1)
    ; store HL in BC
    ld bc,hl

    ;
    ; Find X delta
    ;
    ld e,(ix+motionStruct.countX)
    ld d,(ix+motionStruct.countX+1)
    ;Returns diff in HL
    call Maths.difference16

    ;
    ; Count = delta / step
    ; 

    ld a,(ix+motionStruct.stepX)
    push af,bc,de
    ld e,a
    ; divMod: bc = hl/e
    call Maths.div16_8
    ld (ix+motionStruct.countX),c
    ld (ix+motionStruct.countX+1),b
    
    pop de,bc,af
    ;Negate step if destination < start
    ;DE = dest, BC=start
    ld hl,bc
    or a
    sbc hl,de
    jr c, .destGreater
    jr z, .destGreater
    neg
    ld (ix+motionStruct.stepX),a
    ld (ix+motionStruct.stepX+1),$ff
.destGreater:

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

isFinished:
    ret



    endmodule