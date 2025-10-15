;-----------------------------------------------------------------------------------
; 
; Animation: HoldPalette
; 
; Keeps a sprite's palette offset at 0
; For example, when a tile is slotted, prevent the mouse hover immediately highlighting the tile
; 
;-----------------------------------------------------------------------------------

    module HoldPalette

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 gameId)
;

; In A: game ID
;    HL: Time in 1/50ths
;
; Dirty IX, HL
;
;-----------------------------------------------------------------------------------
start:
    ; A = gameId
    ld (gameId),a

    ld ix,timer1
    call Timing.startTimer
    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_HOLD_PALETTE,(hl)
    ret

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: A, IX
;-----------------------------------------------------------------------------------
update:
    ld a,(gameId)
    call SpriteList.find
    ld a,h
    or l
    ld iy,hl
    jr z, .finished

    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .finished

    xor a
    ld (iy+spriteItem.palette),a
    ret

.finished:
    ;Ensure palette offset is 0
    xor a
    ld (iy+spriteItem.palette),a
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_HOLD_PALETTE,(hl)
    ret


gameId:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule