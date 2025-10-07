;-----------------------------------------------------------------------------------
; 
; Animation: ClearText
; 
; Clears a line of text after a certain time has elapsed
; 
;-----------------------------------------------------------------------------------

    module ClearText

;-----------------------------------------------------------------------------------
;
; Function: start(uint8 duration, uint8 yPos)
;
; In A: duration in 50ths of a second 
;    B: Y position of the line of text to clear
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
start:
    ld (count),a
    ld a,b
    ld (lineYPos),a
    ld hl, Animator.finishedFlags
    res Animator.BIT_CLEAR_TEXT,(hl)
    ret


;-----------------------------------------------------------------------------------
;
; Function: update()
;
; Dirty: A,E,HL
;-----------------------------------------------------------------------------------
update:
    ld a,(count)
    dec a
    ld (count),a
    jr z, stop
    ret    

;-----------------------------------------------------------------------------------
;
; Function: stop()
; 
; Clears the line immediately
;
; Dirty: A,E, HL
;-----------------------------------------------------------------------------------
stop:
    ;set this animation's isFinished flag
    ld hl, Animator.finishedFlags
    set Animator.BIT_CLEAR_TEXT,(hl)

    ld a,(lineYPos)
    ld e,a
    call Print.clearLine
    ret


lineYPos:
    db 0

count:
    db 0
    
    endmodule