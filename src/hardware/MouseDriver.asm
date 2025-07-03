;-----------------------------------------------------------------------------------
;
; Mouse Driver to convert the Kempston mouse's X-Y co-ords to absolute screen co-ords.
; Handles the button press states for clicking and dragging 
; 
;-----------------------------------------------------------------------------------

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
MOUSE_MAX_X:                     equ 310
MOUSE_MAX_Y:                     equ 247

DRAG_BOUNDS_X_MIN:               equ 16
DRAG_BOUNDS_X_MAX:               equ 319 - 16
DRAG_BOUNDS_Y_MIN:               equ 16
DRAG_BOUNDS_Y_MAX:               equ 255 - 16

STATE_READY:                     equ 0
STATE_HOVER:                     equ 1
STATE_HOVER_END:                 equ 2
STATE_PRESSED:                   equ 3
STATE_CLICKED:                   equ 4
STATE_DRAG_START                 equ 5
STATE_DRAG:                      equ 6
STATE_DRAG_OUT_OF_BOUNDS:        equ 7
STATE_DRAG_END:                  equ 8
STATE_CLICKED_OFF:               equ 9
STATE_BACKGROUND_PRESSED:        equ 10
STATE_BACKGROUND_CLICKED:        equ 11

MOUSE_FLAGS_MASK:                equ %00000111
MASK_HOVERABLE:                  equ %00000001
MASK_DRAGABLE:                   equ %00000010
MASK_CLICKABLE:                  equ %00000100
BIT_HOVERABLE:                   equ 0
BIT_DRAGABLE:                    equ 1
BIT_CLICKABLE:                   equ 2

stateJumpTable:
    dw stateReady
    dw stateHover
    dw stateHoverEnd
    dw statePressed
    dw stateClicked
    dw stateDragStart
    dw stateDrag
    dw stateDragOutOfBounds
    dw stateDragEnd
    dw stateClickedOff
    dw stateBackgroundPressed
    dw stateBackgroundClicked

;-----------------------------------------------------------------------------------
;
; Variables
;
;-----------------------------------------------------------------------------------
; Mouse x - coordinate (WORD), 0-319
mouseX:        dw 0
; Mouse y - coordinate 18 bites, 0-255
mouseY:        db 0
; Button pressed flags
buttons:       db 0
; Previous X position from kempston port (0-255)
kempstonX:     db 0
; Previous Y position from kempston port
kempstonY:     db 0
; Mouse state, see STATE_X values above
state:         db 0
; Record the initial gameId when the mouse enters pressed stats
pressedId:     db 0

;-----------------------------------------------------------------------------------
;
; init
; 
; Mouse variable initialization, sets up mouse X-Y and kempston X-Y values
; 
; 
;-----------------------------------------------------------------------------------
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

;-----------------------------------------------------------------------------------
;
; Function: update
;
; Call this function every TV frame to update the Mouse X-Y co-ordinates and 
; button presses
; 
; The kempston X-Y values are relative and need to be converted to absolute
; screen coordinates. Also kempston X is 0-255 and the the screen co-ords are 0-319.
; 
; To convert to absolute co-ords, the kempston XY coords are recorded and on the
; next TV frame, a new set of XY co-ords are read. The difference between the new
; and previous co-ords is applied to the absolute Mouse XY.
;
; The mouse pointer is dampened by halving the XY differences to give more 
; precise control over the pointer as it moves quite quickly.
; 
; 
; Dirty: A, BC, DE, HL
; 
;-----------------------------------------------------------------------------------
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


;-----------------------------------------------------------------------------------
;
; Function: dragOutOfBounds
;
; Call this function when the dragged object is out of bounds
; The the state will immediately change DRAG_OUT_OF_BOUNDS and
; change to READY when the user  releases the mouse button.
; 
;-----------------------------------------------------------------------------------
dragOutOfBounds:
    ld a,(state)
    ; check that the current state is DRAG
    cp STATE_DRAG
    jr nz, .exit
    ; Change state to out of bounds
    ld a,STATE_DRAG_OUT_OF_BOUNDS
    ld (state),a
.exit
    ret

;-----------------------------------------------------------------------------------
;
; Function: updateState(uint8 flags, uint8 id)
;
; This state machine uses a jump table to implement the various states
; Of clicking and dragging
; 
; In - A: Interaction Flags
;       bit 2: Clickable - sprite can be clicked
;       bit 1: Draggable - sprite can be dragged
;       bit 0: Hoverable - sprite will react if pointer is hovering over it 
;
;      C: gameId of object mouse is interacting with, or 0 if not interacting
;
;
; Dirty: AF, BC, DE, HL
; 
;-----------------------------------------------------------------------------------
updateState:
    ; Mask off any other bits, Store flags in B
    and MOUSE_FLAGS_MASK
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

; 
; Waiting for the user to hover over or click on a sprite
;     
stateReady:
    ; Get flags from B and see if any are set
    ld a,b
    or a
    ; Jump if hovering
    jr nz, .hoverAndPressedCheck
    ; Not hovering, but check if pressed
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr nz, .exit
    ; button pressed, but not over any sprite
    ld a, STATE_BACKGROUND_PRESSED
    ld (state),a
.exit:
    ret

.hoverAndPressedCheck:
    ; currently hovering, so save this state
    ld a,STATE_HOVER
    ld (state),a
    ; fall through into stateHover logic to check if button pressed


; 
; The mouse pointer is hovering over a sprite, it the user clicks the
; left mouse button they can begin dragging the sprite     
;
stateHover:
    ;Is the mouse still hovering, check if any flags are set
    ld a,b
    or a
    jr z, .hoverEnd

    ;If mouse is not pressed, stay in the hover state
    ld a,(MouseDriver.buttons)
    bit 1,a
    ld a, STATE_HOVER
    jr nz, .exit
    ; Mouse clicked onto a sprite, check if can be dragged
    ld a, STATE_DRAG_START
    bit BIT_DRAGABLE,b
    jr nz, .exit

    ; Can sprite be clicked
    bit BIT_CLICKABLE,b
    jr nz, .pressed

    ;Treat sprite as background
    ld a, STATE_BACKGROUND_PRESSED
.exit:
    ld (state),a
    ret

.pressed:
    ;Store id of the sprite being pressed
    ld a,c
    ld (pressedId),a
    ld a, STATE_PRESSED
    ld (state),a
    ret


.hoverEnd:
    ld a,STATE_HOVER_END
    ld (state),a
    ret

; 
; This state is to notify when the mouse has stopped hovering
;
stateHoverEnd:
    ld a, STATE_READY
    ld (state),a
.exit:
    ret


; 
; The user has begun dragging a sprite, a client function should
; record the start position of the drag
;     
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


; 
; The user is currently dragging the sprite:
; Check if the mouse button has been released and
; check if the pointer is in bounds
;    
stateDrag:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; Button release
    ld a, STATE_DRAG_END
    ld (state),a
.exit:
    ret

; 
; The user has dragged the pointer out of bounds 
; Wait for the user to release the mouse button
;    
stateDragOutOfBounds:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; Button release
    ld a, STATE_READY
    ld (state),a
.exit:
    ret

statePressed:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; No longer pressed
    ; Does pressId match Id
    ld a,(pressedId)
    cp c
    ld a, STATE_CLICKED_OFF
    jr nz, .clickedOff

    ld a, STATE_CLICKED
.clickedOff:
    ld (state),a
.exit:
    ret


;
; Call mouseOver to see which sprite has been clicked
;
stateClicked:
    ; clear pressedId
    xor a
    ld (pressedId),a
    ld a, STATE_READY
    ld (state),a
    ret


; 
; The user has stopped dragging a sprite, so go back to the ready state
;     
stateDragEnd:
    ld a, STATE_READY
    ld (state),a
    ret


;
; The user clicked on a sprite, but then moved the pointer off the sprite
;
stateClickedOff:
    ; clear pressedId
    xor a
    ld (pressedId),a
    ld a, STATE_READY
    ld (state),a
    ret

;
; The user did not press on a sprite
;
stateBackgroundPressed:
    ld a,(MouseDriver.buttons)
    bit 1,a
    jr z, .exit
    ; No longer pressed
    ld a, STATE_BACKGROUND_CLICKED
    ld (state),a
.exit:
    ret

;
; The user did not press/click on a sprite
;
stateBackgroundClicked:
    ld a, STATE_READY
    ld (state),a
    ret



    endmodule
