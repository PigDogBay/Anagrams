;-----------------------------------------------------------------------------------
; 
; Module Joystick
;
; Code for the Kempston Joystick control, it will affect the 
; MouseDriver's X,Y and L button settings
; 
;-----------------------------------------------------------------------------------

    module Joystick

; Kempston port 1
; Bit set = pressed
; Bit 5 = C button
; Bit 6 = A button
; Bit 7 = Start button
JOY_PORT_F_U_D_L_R               equ $1f
KEMPSTON_MASK                    equ $20

update:
    ld a, KEMPSTON_MASK
    in a,(JOY_PORT_F_U_D_L_R)
    ld b,a ;Store A

    bit 0,a
    call nz, rightPressed
    bit 1,a
    call nz, leftPressed:
    bit 2,a
    call nz, downPressed:
    ld a,b ;Restore A
    bit 3,a
    call nz, upPressed:

    ld a,b ;Restore A
    bit 4,a
    ld a,MouseDriver.JOYSTICK_FIRE_PRESSED
    jr nz, .firePressed
    ld a,b ;Restore A
    ;Fire button 2 (C) is same as right mouse button
    bit 5,a
    ld a,MouseDriver.JOYSTICK_FIRE2_PRESSED
    jr nz, .firePressed
    ld a,MouseDriver.JOYSTICK_NOT_PRESSED
.firePressed
    ld (MouseDriver.joystickFire),a
    ret

upPressed:
    ld a, (MouseDriver.mouseY)
    dec a
    dec a
    ld (MouseDriver.mouseY),a
    ret
downPressed:
    ld a, (MouseDriver.mouseY)
    inc a
    inc a
    ld (MouseDriver.mouseY),a
    ret
leftPressed:
    ld hl, (MouseDriver.mouseX)
    dec hl
    dec hl
    ld (MouseDriver.mouseX),hl
    ret
rightPressed:
    ld hl, (MouseDriver.mouseX)
    inc hl
    inc hl
    ld (MouseDriver.mouseX),hl
    ret

    endmodule