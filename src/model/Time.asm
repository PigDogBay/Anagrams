;-----------------------------------------------------------------------------------
; Module Time
;
; Handles the count down timer
;
; 
;-----------------------------------------------------------------------------------
    module Time

TICK_COUNTER_MAX    equ 50          ;50 ticks equal 1s on 50Hz machines

;-----------------------------------------------------------------------------------
; 
; Function: reset() -> uint16 time
;
; Resets the time to the yearStartTime
;
; Out: HL time
; 
;-----------------------------------------------------------------------------------
reset:
    ld hl,(yearStartTime)
    ld (time),hl
    ret

;-----------------------------------------------------------------------------------
; 
; Function: decreaseStartTime()
;
; The start time at the beginning of the round is decreased, this will
; make later levels harder
;
; 
;-----------------------------------------------------------------------------------
decreaseStartTime:
    ld hl,(yearStartTime)
    ld de, (roundDecrease)
    sbc hl,de
    ld (yearStartTime),hl
    ret


;-----------------------------------------------------------------------------------
; 
; Function: onTick()
;
; Decreases the time by 1s every 50th call
;
; Dirty: A,HL
; 
;-----------------------------------------------------------------------------------
onTick
    ld a,(tickCounter)
    cp TICK_COUNTER_MAX
    jr z, .decreaseTime
    inc a
    ld (tickCounter),a
    ret

.decreaseTime
    ;reset counter
    xor a
    ld (tickCounter),a
    ld hl, (time)
    ;Is time 0?
    ld a,l
    or h
    jr z, .zeroTime
    dec hl
    ld (time),hl
.zeroTime:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: printToBuffer()
;
; Prints the time to the Print.buffer, appends 's' for seconds
;
; Out: HL - points to null terminator
;   
; Dirty: A,DE,HL
; 
;-----------------------------------------------------------------------------------
printToBuffer:
    ld de, Print.buffer
    ld hl,(time)
    ld a,1
    call ScoresConvert.ConvertToDecimal
    ;point to the end of the string
    ex de,hl
    add hl,a
    ;Print second units
    ld (hl), 's'
    inc hl
    ;pad with spaces (to clear printing area on the screen)
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ;null terminate
    ld (hl), 0

    ret

roundDecrease:          dw 10
yearStartTime:          dw 300          ;Starting time each year
time:                   dw 42            ;Time in seconds
tickCounter:            db 0

    endmodule
