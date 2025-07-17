;-----------------------------------------------------------------------------------
; 
; Animation: Flash
; 
; Select a tile, reveal which slot it belongs to 
; click background to cancel
; 
;-----------------------------------------------------------------------------------

    module Flash

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 tileId)
;
; Rapidly changes the palette of the tile to make it flash
;
; In A: game ID
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

    ;Found sprite
    ld (spritePtr),hl

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
    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .finished

    ld a,(paletteOffset)
    inc a
    ld (paletteOffset),a
    and %00001111
    ;Palette is bits 7-4
    sla a: sla a: sla a: sla a
    ld ix, (spritePtr)
    ld (ix+spriteItem.palette),a
    ret

.finished:
    ;Restore palette
    xor a
    ld ix, (spritePtr)
    ld (ix+spriteItem.palette),a
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_FLASH,(hl)
    ret


spritePtr:
    dw 0
paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0

    endmodule