;-----------------------------------------------------------------------------------
; 
; Animation: FlashTwo
; 
; Flashes two sprites by rapidly changing their palettes
; 
;-----------------------------------------------------------------------------------

    module FlashTwo

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 gameId1, uint8 gameId2, uint8 duration)
;
; Rapidly changes the palette of two sprites to make them flash
;
; In A: game ID of sprite 1
;    B: game ID of sprite 2
;    C: duration in ticks (50/60Hz)
; Dirty IX, HL
;
;-----------------------------------------------------------------------------------
start:
    ; A = gameId
    ld (gameId1),a
    ld a,b
    ld (gameId2),a

    ld ix,timer1
    ld h,0
    ld l,c
    call Timing.startTimer
    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_FLASHTWO,(hl)

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: A, IX
;-----------------------------------------------------------------------------------
update:
    ld a,(gameId1)
    call SpriteList.find
    ld a,h
    or l
    ld iy,hl
    jr z, .finished

    ld a,(gameId2)
    call SpriteList.find
    ld a,h
    or l
    jr z, .finished


    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .finished

    ld a,(paletteOffset)
    inc a
    ld (paletteOffset),a
    and %00000111
    ;Palette is bits 7-4
    sla a: sla a: sla a: sla a:sla a

    ld ix,hl
    ld (ix+spriteItem.palette),a
    ld (iy+spriteItem.palette),a
    ret

.finished:
    ;Restore palette
    xor a
    ld ix,hl
    ld (ix+spriteItem.palette),a
    ld (iy+spriteItem.palette),a
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_FLASHTWO,(hl)
    ret


gameId1:
    db 0
gameId2:
    db 0
paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule