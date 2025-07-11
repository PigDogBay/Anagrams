;-----------------------------------------------------------------------------------
; 
; Module: Timing
; 
; 16-bit timer, at 50Hz can time upto 32767*20ms (~65 seconds)
; 
;-----------------------------------------------------------------------------------

    module Timing


;-----------------------------------------------------------------------------------
; 
; Struct: timingStruct
; 
; Contains the data needed by the timing function, each timed event should use their
; own timingStruct
; 
;-----------------------------------------------------------------------------------
    struct @timingStruct
duration    word
startCount  word
endCount    word
    ends


;-----------------------------------------------------------------------------------
; 
; Function: onTick()
; 
; Call this function periodically (eg before each screen refresh) to increase the tick count
; 50Hz refresh, each tick represents 20ms
; 60Hz refresh, 16.667ms
; 
; Dirty: HL
; 
;-----------------------------------------------------------------------------------
onTick:
    ld hl,(tickCount)
    inc hl
    ld (tickCount),hl
    ret


;-----------------------------------------------------------------------------------
; 
; Function: startTimer(uint16 ptr, uint16 duration)
; 
; Sets up the timingStruct. Call this function at the start of a timed task.
;
; In: IX - pointer to the timingStruct
;     HL - duration (in ticks)
; 
;-----------------------------------------------------------------------------------
startTimer:
    push de
    push hl

    ;Set duration
    ld (ix),l
    ld (ix+1),h

    ex de,hl

;Shared code between startTimer and restartTimer
;(or tasty spaghetti, just needs a sprinkle of self-modification)
;
; In: IX - pointer to the timingStruct
;     DE - duration (in ticks)
;
.setStartEndCounts:
    ld hl,(tickCount)
    ld (ix + timingStruct.startCount),l
    ld (ix + timingStruct.startCount+1),h

    ;endCount = startCount + duration 
    add hl,de
    ld (ix + timingStruct.endCount),l
    ld (ix + timingStruct.endCount+1),h

    pop hl
    pop de
    ret


;-----------------------------------------------------------------------------------
; 
; Function: restartTimer(uint16 ptr)
; 
; Restarts the timer: 
;     startCount = tick count
;     endCount = startCount + duration
;
; In: IX - pointer to the timingStruct
; 
;-----------------------------------------------------------------------------------
restartTimer:
    push de
    push hl

    ;Get duration already set
    ld e,(ix)
    ld d,(ix+1)

    jr startTimer.setStartEndCounts


;-----------------------------------------------------------------------------------
; 
; Function: hasTimerElapsed(uint16 ptr) -> Boolean
; 
; Poll this function to determine if the timer has elapsed.
;
; 
;  In: IX - pointer to the timingStruct
; Out: Z flag nz not set = true elapsed, z set = false, not elapsed
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
hasTimerElapsed:
    push de,hl

    ;BC = tickCount, DE = startCount, HL = endCount
    ld bc,(tickCount)
    ld e,(ix + timingStruct.startCount)
    ld d,(ix + timingStruct.startCount+1)
    ld l,(ix + timingStruct.endCount)
    ld h,(ix + timingStruct.endCount+1)

    ;clear carry
    or a
    sbc hl,de
    jr nc, .endGtEqStart

    ;
    ; endCount < startCount
    ;

    ;restore HL
    add hl,de
    ;IF tickCount <= endCount THEN still ticking
    or a
    sbc hl,bc
    jr  z, .elasped
    jr nc, .stillTicking

    ; So tickCount > endCount
    ; IF tickCount < startCount THEN elapsed
    ex hl,de
    or a
    sbc hl,bc
    jr  z, .stillTicking
    jr nc, .elasped
    jr .stillTicking


    ;
    ; endCount >= startCount
    ;
.endGtEqStart:
    ;restore HL
    add hl,de
    ;IF tickCount >= endCount THEN elapsed
    or a
    sbc hl,bc
    jr z, .elasped
    jr c, .elasped

    ; So tickCount < endCount
    ;IF tickCount < startCount THEN elapsed
    ex hl,de
    or a
    sbc hl,bc
    jr  z, .stillTicking
    jr nc, .elasped

.stillTicking:
    xor a
    pop hl,de
    ret

.elasped:
    ld a,1
    or a
    pop hl,de
    ret


; Private field to store the current time
tickCount:
    dw 0



    endmodule