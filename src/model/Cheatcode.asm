;-----------------------------------------------------------------------------------
;
; Module Cheatcode
; 
; State machine for the cheat code
; 
;-----------------------------------------------------------------------------------
    module Cheatcode

CHEAT_WAIT_PRESS        equ 0
CHEAT_WAIT_NO_PRESS     equ 1
CHEAT_ACTIVATE          equ 2

MAX_INDEX_VALUE         equ 9

;-----------------------------------------------------------------------------------
; 
; Function: update
;
; Updates the state machine with the latest char press / non press
;
;  In: A - Latest key press value
;   
; Dirty: A,HL
; 
;-----------------------------------------------------------------------------------
update:
    ld b,a
    ld a,(state)
    cp CHEAT_WAIT_PRESS
    jr z, waitPress
    cp CHEAT_WAIT_NO_PRESS
    jr z, waitNoPress
    cp CHEAT_ACTIVATE
    jr z, activate
    ret

waitPress:
    ;Has a key been pressed?
    ld a,b
    or a
    ret z

    ;get expected key
    ld hl, code
    ld a,(indexIntoCode)
    add hl,a
    ld a,(hl)
    ;compare with current key press
    cp b
    jr nz, reset

    ;Try next index
    ld a,(indexIntoCode)
    inc a
    ld (indexIntoCode),a

    ;Was it entered
    cp MAX_INDEX_VALUE
    jr z, .cheatEntered

    ;Wait for user to lift their finger off the key
    ld a, CHEAT_WAIT_NO_PRESS
    ld (state),a
    ret
.cheatEntered:
    ld a, CHEAT_ACTIVATE
    ld (state),a
    ret
    
waitNoPress:
    ld a,b
    or a
    jr  nz, .exit
    ;no key pressed, so now wait for a key press
    ld a, CHEAT_WAIT_PRESS
    ld (state),a
.exit:
    ret

activate:
reset:
    xor a
    ld (indexIntoCode),a
    ld a,CHEAT_WAIT_NO_PRESS
    ld (state),a
    ret



state:
    db CHEAT_WAIT_PRESS
code:
    db "UPSCUMBAG"
indexIntoCode:
    db 0


    endmodule
