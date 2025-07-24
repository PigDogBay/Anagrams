;-----------------------------------------------------------------------------------
; 
; Animation: MoveSprites
; 
; Moves a sprite to a location
; 
;-----------------------------------------------------------------------------------

    module MoveSprites
    

;-----------------------------------------------------------------------------------
;
; Function: start(uint16 motionStruct)
;
;
; In    A:  number of items
;       IX: pointer to first motion struct
;
;-----------------------------------------------------------------------------------
start:
    ld (count),a
    ld (pointer),ix

    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_MOVE,(hl)

    ret

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: A, IX
;-----------------------------------------------------------------------------------
update:
    ld ix,(pointer)
    call Motion.isStillMoving
    jr z, .finished

    ld a, (ix + motionStruct.delay)
    or a
    jr nz, .delay

    ld a,(ix + motionStruct.gameId)
    call SpriteList.find
    ld a,h
    or l
    jr z, .finished
    ld iy,hl    

    ;ix = motionStruct
    ;iy = spriteItem
    call Motion.updateX
    call Motion.updateY
    ret

.finished:
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_MOVE,(hl)
    ret

.delay:
    dec a
    ld (ix + motionStruct.delay),a
    ret



count:
    db 0
pointer:
    dw 0

    endmodule