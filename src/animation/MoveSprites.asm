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
; Function: add(uint16 ptrMotion)
;
; Adds a new appearStruct to the list
; In: IX - Pointer to motion struct
;
; Dirty: A,BC,DE,HL,IY
;
;-----------------------------------------------------------------------------------
add:
    push ix
    ld a,(ix + motionStruct.gameId)
    call SpriteList.find
    ld a,h
    or l
    ;Exit if sprite not found
    jr z, .finished
    ld iy,hl    

    ;copy struct to list
    ld bc,motionStruct
    ld hl,ix
    ld de,(nextEntryPtr)
    ldir

    ld ix,(nextEntryPtr)
    ;In IX - motionStruct, IY - spriteItem
    call Motion.initMoveToXY


    ; Increase count by 1
    ld a,(count)
    inc a
    ld (count),a
    ;Move pointer to top of list
    ld hl,(nextEntryPtr)
    add hl, motionStruct
    ld (nextEntryPtr),hl

.finished:
    pop ix
    ret

;-----------------------------------------------------------------------------------
;
; Function: start()
;
; Clears the animation finished flag or the animation
;
;-----------------------------------------------------------------------------------
start:
    ; check if list contains any motion items
    ld a,(count)
    or a
    ret z

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
    ld ix,list
.next:
    call updateItem
    ld de, motionStruct
    add ix,de
    djnz .next
    jr checkIfFinished

;-----------------------------------------------------------------------------------
;
; Function: private updateItem(uint16 motionPtr)
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
    ld ix,list
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


nextEntryPtr:
    dw list
count:
    db 0
list:
    ;32 should be enough
    block motionStruct * 32

    endmodule