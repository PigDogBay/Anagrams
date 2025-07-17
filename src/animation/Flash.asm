;-----------------------------------------------------------------------------------
; 
; Animation: Flash
; 
; Flashes a sprite by rapidly changing its palette
; 
;-----------------------------------------------------------------------------------

    module Flash

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 gameId)
;
; Rapidly changes the palette of the sprite to make it flash
;
; In A: game ID
;
; Dirty IX, HL
;
;-----------------------------------------------------------------------------------
start:
    ; A = gameId
    ld (gameId),a

    ld ix,timer1
    ld hl,100
    call Timing.startTimer
    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_FLASH,(hl)
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

    ld a,(paletteOffset)
    inc a
    ld (paletteOffset),a
    and %00001111
    ;Palette is bits 7-4
    sla a: sla a: sla a: sla a
    ld (iy+spriteItem.palette),a
    ret

.finished:
    ;Restore palette
    xor a
    ld (iy+spriteItem.palette),a
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_FLASH,(hl)
    ret


gameId:
    db 0
paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule