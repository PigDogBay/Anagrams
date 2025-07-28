;-----------------------------------------------------------------------------------
; 
; Animation: Visibility
; 
; Toggles the visibility flag of a sprite after a delay, clients can specify a list
; of gameId of each sprite and specific delay for the sprite
; 
;-----------------------------------------------------------------------------------

    module Visibility

    struct @visibilityStruct
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
; Function: setAllVisibility(bool isVisible)
; Finds the sets/clears the visibility flag on all matching spriteItems
;
; In: A - 1 is visible, 0 invisible
;
; Dirty: A,B, DE, HL
;-----------------------------------------------------------------------------------
setVisibility:
    ld c,a
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
    ld a,c
    or a
    jr z, .continue
    set BIT_SPRITE_VISIBLE,(hl)

.continue
    ;point to next appearStruct
    inc de
    inc de
    djnz .next
    ret


;-----------------------------------------------------------------------------------
;
; Function: start()
;
; Dirty: HL
;
;-----------------------------------------------------------------------------------
start:
    ;clear this animation's isFinished flag
    ld hl, Animator.finishedFlags
    res Animator.BIT_APPEAR,(hl)
    ret

;-----------------------------------------------------------------------------------
;
; Function: update()
;
; list.forEach { item ->
;     continue if item.delay == 0
;     item.delay--
;     if item.delay == 0 {
;         find sprite
;         toggle sprites visibility flag
;     }
; }
; checkIfFinished()
;
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
update:
    ld a,(count)
    ld b,a
    ld de, list
.next:
    ;c = gameId
    ld a,(de) : ld c,a
    ; a = delay
    inc de : ld a,(de)
    or a
    jr z, .continue
    dec a
    ld (de),a
    or a
    jr nz, .continue
    ;Item's delay has expired, make sprite visible
    ;SpriteList.find
    ; In:    A - game ID
    ; Out:   HL - ptr to sprite's struct
    ld a,c
    call SpriteList.find
    add hl,spriteItem.pattern
    ;No going to check if HL is 0, as set will have no effect on ROM
    ;Toggle visibility
    ld a,SPRITE_VISIBILITY_MASK
    xor (hl)
    ld (hl),a

.continue:
    ;point to next item
    inc de
    djnz .next
    jr checkIfFinished


;-----------------------------------------------------------------------------------
;
; Function: private checkIfFinished()
;
; Checks to see if all delay values are zero, if so then the finished flag is set 
; for this animation
;
; Dirty: A, B, HL
;-----------------------------------------------------------------------------------
checkIfFinished:
    ld a,(count)
    ld b,a
    ld hl, list
    inc hl
.next:
    ;Check if all delays are 0
    ld a,(hl)
    or a
    ret nz
    ;point to next delay value
    inc hl : inc hl
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
    block visibilityStruct * 64


    endmodule