    module MouseDriver
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

STATE_READY:                     equ 0
STATE_HOVER:                     equ 1
STATE_PRESSED:                   equ 2
STATE_CLICKED:                   equ 3
STATE_DRAG_START                 equ 4
STATE_DRAG:                      equ 5
STATE_DRAG_END:                  equ 6

stateJumpTable:
    dw stateReady
    dw stateHover
    dw statePressed
    dw stateClicked
    dw stateDragStart
    dw stateDrag
    dw stateDragEnd

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



;
; In - A: sprite ID if pointer is over a sprite, 0 if not
updateState:
    ; Store spriteId in B
    ld b,a
    ld a,(state)
    ld hl, stateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl
    
stateReady:
    ; Get spriteId
    ld a,b
    or a
    ; Jump if hovering
    jr nz, .hoverAndPressedCheck
    ; Not hovering, but check if pressed
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr nz, .exit
    ; button pressed, but not over any sprite
    ld a, STATE_PRESSED
    ld (state),a
.exit:
    ret

.hoverAndPressedCheck:
    ; currently hovering, so save this state
    ld a,STATE_HOVER
    ld (state),a
    ; fall through into stateHover logic to check if button pressed

stateHover:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr nz, .exit
    ; Mouse clicked onto a sprite
    ld a, STATE_DRAG_START
    ld (state),a
.exit:
    ret

stateDragStart:
    ld a,(MouseDriver.buttons)
    bit 1,a
    ld a, STATE_DRAG
    jr z, .exit
    ; Button release
    ld a, STATE_DRAG_END
.exit:
    ld (state),a
    ret

stateDrag:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; Button release
    ld a, STATE_DRAG_END
    ld (state),a
.exit:
    ret

statePressed:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; No longer pressed, go back to ready state
    ld a, STATE_READY
    ld (state),a
.exit:
    ret

stateClicked:
.exit:
    ret

stateDragEnd:
    ld a, STATE_READY
    ld (state),a
    ret


;Variables

mouseX:        dw 0
mouseY:        db 0
buttons:       db 0
kempstonX:     db 0
kempstonY:     db 0
state:         db 0

    endmodule
