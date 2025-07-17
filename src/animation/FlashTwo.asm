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
; Function: start(uint8 gameId1, uint8 gameId2)
;
; Rapidly changes the palette of two sprites to make them flash
;
; In A: game ID of sprite 1
;    B: game ID of sprite 2
;
; Dirty IX, HL
;
;-----------------------------------------------------------------------------------
start:
    ; A = gameId
    call SpriteList.find
    ld a,h
    or l
    ret z
    ;Found sprite1
    ld (spritePtr1),hl

    ld a,b
    call SpriteList.find
    ld a,h
    or l
    ret z
    ;Found sprite 2
    ld (spritePtr2),hl

    ld ix,timer1
    ld hl,100
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
    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .finished

    ld a,(paletteOffset)
    inc a
    ld (paletteOffset),a
    and %00001111
    ;Palette is bits 7-4
    sla a: sla a: sla a: sla a
    ld ix, (spritePtr1)
    ld (ix+spriteItem.palette),a
    ld ix, (spritePtr2)
    ld (ix+spriteItem.palette),a
    ret

.finished:
    ;Restore palette
    xor a
    ld ix, (spritePtr1)
    ld (ix+spriteItem.palette),a
    ld ix, (spritePtr2)
    ld (ix+spriteItem.palette),a
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_FLASHTWO,(hl)
    ret


spritePtr1:
    dw 0
spritePtr2:
    dw 0
paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule