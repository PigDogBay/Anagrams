    module mouse
; Bits:
; 7-4 wheel delta
; 3 4th button
; 2 Middle
; 1 Left
; 0 Right
MOUSE_PORT_BUTTONS:              equ $FADF
MOUSE_PORT_X:                    equ $FBDF
MOUSE_PORT_Y:                    equ $FFDF
MOUSE_ACCELERATION_THRESHOLD:    equ 16
MOUSE_MAX_X:                     equ 310
MOUSE_MAX_Y:                     equ 247

init:
    ; Initialize kempston x and y values
    ld bc, MOUSE_PORT_X
    in a, (c)
    ld (kempstonX), a
    ld bc, MOUSE_PORT_Y
    in a, (c)
    ld (kempstonY), a

    ; Centre mouse position
    ld a, MOUSE_MAX_X / 2
    ld (mouseX), a
    ld a, MOUSE_MAX_Y / 2
    ld (mouseY), a
    ret

update:
    ; Buttons
    ld bc, MOUSE_PORT_BUTTONS
    in a,(c)
    ld (buttons),a

    ;X Position
    ld hl,kempstonX
    ld bc, MOUSE_PORT_X
    ; Old kempstonX
    ld e,(hl)
    ; New kempstonX
    in a, (c)
    ;Save new kempstonX
    ld (hl), a
    ; Check if moving left or right
    sub e
    cp $80
    jr nc,.movingLeft

; Mouse moving right
    ld hl,(mouseX)
    ;Dampen the mouse movement by dividing by 2
    srl a
    ld e,a
    ld d,0
    add hl,de
    cp MOUSE_ACCELERATION_THRESHOLD
    jr c, .noAccelerationX
    ; Add delta again to boost speed
    add hl,de
.noAccelerationX
    ; Check if mouse is out of bounds
    ex de,hl
    ld hl,MOUSE_MAX_X
    ; Clear carry
    or a
    sbc hl,de
    jr c, .rightEdge
    ld (mouseX), de
    jr .vertical
.rightEdge
    ld hl,MOUSE_MAX_X
    ld (mouseX), hl
    jr .vertical
.movingLeft:
    ld hl,(mouseX)
    ; A is negative (128-255, convert to 0-127)
    neg
    ; Dampen the mouse movement by dividing by 2
    srl a
    ld e,a
    ld d,0
    ; clear carry
    or a
    ; subtract delta from mouseX
    sbc hl,de
    cp MOUSE_ACCELERATION_THRESHOLD
    jr c, .noAccelerationLeftX
    ; Accelerate by subtracting delta again
    sbc hl,de
.noAccelerationLeftX
    ; Check if mouse is out of bounds
    ; Put new mouse position in DE
    ex de,hl
    ld hl,(mouseX)
    or a
    ; if de>hl then mouseX is out of bounds
    sbc hl,de
    jr c, .leftEdge
    ; mouseX is in bounds
    ld (mouseX), de
    jr .vertical
.leftEdge
    ld hl,0
    ld (mouseX),hl
.vertical:
    ; Sprite origin is at the top of the screen
    ; Kempstons origin is at the bottom of the screen
    ld hl,kempstonY
    ld bc, MOUSE_PORT_Y
    ; Old kempstonY
    ld e,(hl)
    ; new kempstonY
    in a, (c)
    ld (hl), a
    sub e
    cp $80
    jr c,.movingUp
    ;
    ; Mouse moving down
    neg
    ; Dampen the mouse movement by dividing by 2
    srl a
    ld e,a
    ld a,(mouseY)
    add e
    jr c, .bottomEdge
    cp MOUSE_MAX_Y
    jr nc, .bottomEdge
    ld (mouseY), a
    ret
.bottomEdge:
    ld a,MOUSE_MAX_Y
    ld (mouseY), a
    ret
.movingUp:
    ; Dampen the mouse movement by dividing by 2
    srl a
    ld e,a
    ld a,(mouseY)
    sub e
    jr nc, .notTopEdge
    xor a
.notTopEdge:
    ld (mouseY), a
    ret

mouseX:        dw 0
mouseY:        db 0
buttons:       db 0
kempstonX:     db 0
kempstonY:     db 0

    endmodule
