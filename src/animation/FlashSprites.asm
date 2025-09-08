;-----------------------------------------------------------------------------------
; 
; Animation: FlashSprites
; 
; Flashes a list of sprites by rapidly changing their palette in sequence
; 
;-----------------------------------------------------------------------------------

    module FlashSprites

copyAllTileIds:
    ld a,(Tile.tileCount)
    ld b,a
    ld hl,Tile.tileList
    ld de, idList
.loop:
    ld a,(hl)
    ld (de),a
    add hl,tileStruct
    inc de
    djnz .loop

    ;null terminate the list
    xor a
    ld (de),a

    ret
;-----------------------------------------------------------------------------------
;
; Function: start(uint16 duration)
;
; Set up animation
;
; In HL: duration
;
; Dirty IX, HL
;
;-----------------------------------------------------------------------------------
start:
    xor a
    ld (index),a
    ld a,1
    ld (paletteOffset),a

    ;HL = duration parameter
    ld ix,timer1
    call Timing.startTimer
    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_FLASH_SPRITES,(hl)
    ret

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: A, IX
;-----------------------------------------------------------------------------------
update:
    ;Has animation timed out?
    ld ix,timer1
    call Timing.hasTimerElapsed
    jr nz, .finished

    ;get current Id
    ld hl, idList
    ld a,(index)
    add hl,a
    ld a,(hl)
    ;Copy into B
    ld b,a

    ;Is ID==0
    or a
    jr nz, .findSprite

    ld (index),a
    ;increase palette offset
    ld a,(paletteOffset)
    inc a
    ld (paletteOffset),a
    ;try again
    jr update
    
.findSprite:
    ;Inc index for next time
    ld a,(index)
    inc a
    ld (index),a

    ;find sprite
    ld a,b
    call SpriteList.find
    ld a,h
    or l
    jr z, .finished

    ;Update sprite's palette
    ld a,(paletteOffset)
    and %00001111
    ;Palette is bits 7-4
    sla a: sla a: sla a: sla a
    add hl,spriteItem.palette
    ld (hl),a
    ret

.finished:
    ;Reset palette offset for each sprite
    ld hl,idList
.next:
    ld a,(hl)
    or a
    jr z, .done
    ;point to next id
    inc hl
    ex de,hl

    call SpriteList.find
    ;Exit if we didn't find the sprite
    ld a,h
    or l
    jr z, .done

    ;HL points to spriteItem
    add hl,spriteItem.palette
    xor a
    ld (hl),a
    ;restore pointer to idList
    ex de,hl
    jr .next

.done:
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_FLASH_SPRITES,(hl)
    ret

paletteOffset:
    db 0
timer1:
    timingStruct 0,0,0
index:
    db 0
idList:
    ds 64

    endmodule