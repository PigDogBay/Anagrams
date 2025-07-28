;-----------------------------------------------------------------------------------
; 
; Animation: Appear
; 
; Sets a list of sprites to invisible, after a delay, the sprites become visible and
; the animation end
; 
;-----------------------------------------------------------------------------------

    module Appear

    struct @appearStruct
gameId      byte
delay       byte
    ends


;-----------------------------------------------------------------------------------
;
; Function: removeAll
;
; Resets counter
;
; Dirty A, HL
;-----------------------------------------------------------------------------------
removeAll:
    xor a
    ld (count),a
    ; Point to the start of the list
    ld hl,list
    ld (nextEntryPtr),hl
    ret

;-----------------------------------------------------------------------------------
;
; Function: add(uint8 id, uint8 delay)
;
; Adds a new appearStruct to the list
; In:
;       B - game Id of the sprite
;       C - delay
;
; Dirty: A, HL
;
;-----------------------------------------------------------------------------------
add:
    ; Increase count by 1
    ld a,(count)
    inc a
    ld (count),a
    ld hl,(nextEntryPtr)
    ld (hl),b
    inc hl
    ld (hl),c
    inc hl
    ld (nextEntryPtr),hl
    ret

;-----------------------------------------------------------------------------------
;
; Function: start()
;
;
; Dirty: A,B, DE, HL
;-----------------------------------------------------------------------------------
start:
    ; set all sprites in the list to invisible
    ld a,(count)
    ld b,a
    ld de, list
.next:
    ;SpriteList.find
    ; In:    A - game ID
    ; Out:   HL - ptr to sprite's struct
    ld a, (de)
    call SpriteList.find
    add hl,spriteItem.pattern
    res BIT_SPRITE_VISIBLE,(hl)
    ;point to next appearStruct
    inc de
    inc de
    djnz .next

    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_APPEAR,(hl)
    ret

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: 
;-----------------------------------------------------------------------------------
update:
    ld a,(count)
    ld b,a
    ld de, list
.next:
    ;SpriteList.find
    ; In:    A - game ID
    ; Out:   HL - ptr to sprite's struct
    ld a, (de)
    call SpriteList.find


    djnz .next
    jr checkIfFinished


;-----------------------------------------------------------------------------------
;
; Function: private checkIfFinished()
;
; Dirty: 
;-----------------------------------------------------------------------------------
checkIfFinished:
    ld a,(count)
    ld b,a
.next:
    ;Check if all delays are 0
    djnz .next

    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_APPEAR,(hl)
    ret


nextEntryPtr:
    dw list

count:
    db 0
list:
    ;64 should be enough
    block appearStruct * 64


    endmodule