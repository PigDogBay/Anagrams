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
; Dirty: All
;-----------------------------------------------------------------------------------
update:
    ld a,(count)
    ld b,a
    ld ix,(pointer)
.next:
    call updateItem
    ld de, motionStruct
    add ix,de
    djnz .next
    jr checkIfFinished

;-----------------------------------------------------------------------------------
;
; Function: updateItem(uint16 motionPtr)
;
; In: IX pointer to motion struct
;
; Dirty: A, DE, HL, IY
;-----------------------------------------------------------------------------------
updateItem:
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

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: All
;-----------------------------------------------------------------------------------
checkIfFinished:
    ld a,(count)
    ld b,a
    ld ix,(pointer)
    ld de, motionStruct
.next:
    ;Check if all counts are 0
    ld l,(ix + motionStruct.countX)
    ld h,(ix + motionStruct.countX+1)
    ld a,(ix + motionStruct.countY)
    or l
    or h
    ret nz
    add ix,de
    djnz .next

    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_MOVE,(hl)
    ret


count:
    db 0
pointer:
    dw 0

    endmodule