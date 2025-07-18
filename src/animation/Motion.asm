;-----------------------------------------------------------------------------------
; 
; Animation: Motion
; 
; Moves a sprite to a location
; 
;-----------------------------------------------------------------------------------

    module Motion
    
    struct @motionStruct
gameId      byte
stepX       word
countX      word
stepY       byte
countY      byte
isDone      byte
    ends

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 gameId1, uint8 gameId2, uint8 duration)
;
; Rapidly changes the palette of two sprites to make them flash
;
; In A: game ID of sprite
;    HL: X co-ord of destination
;    D: Y co-ord of destination
;    E: Steps
;
;-----------------------------------------------------------------------------------
start:
    ; A = gameId
    ld (gameId),a

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
    ld a,(countY)
    or a
    jr nz,.stillMoving
    ld a,(countX)
    or a
    jr z, .finished

.stillMoving:
    ld a,(gameId)
    call SpriteList.find
    ld a,h
    or l
    jr z, .finished
    ld ix,hl

    call updateX
    call updateY
    ret

.finished:
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_MOVE,(hl)
    ret


updateY:
    ld a,(countY)
    or a
    ret z
    dec a
    ld (countY),a
    ld l,(ix+spriteItem.y)
    ld a,(stepY)
    add a,l
    ld (ix+spriteItem.y),a
    ret

updateX:
    ld a,(countX)
    or a
    ret z
    dec a
    ld (countX),a
    ld e,(ix+spriteItem.x)
    ld d,(ix+spriteItem.x+1)
    ld hl,(stepX)
    add hl,de
    ld (ix+spriteItem.x),l
    ld (ix+spriteItem.x+1),h
    ret

count:
    db 0
motionPtr:
    dw 0


gameId:
    db 0
stepX:
    dw 65535
stepY:
    db 255
countY: 
    db 150
countX: 
    db 150

    endmodule