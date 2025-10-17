;-----------------------------------------------------------------------------------
; 
; State: Transition
; 
; Fades out the current screen, fades in the new using tilemap rectangles
;
; Use the macro TRANSITION_SCREEN 
; 
;-----------------------------------------------------------------------------------

    module GameState_Transition

RECT_LEN            equ 6
RECT_COUNT          equ 20
TRANSPARENT_TILE:   equ 0
OPAQUE_TILE:        equ 97

;States
RECT_STATE_START:   equ 0
RECT_STATE_IN:      equ 1
RECT_STATE_OUT:     equ 2
RECT_STATE_DONE:    equ 3
RECT_STATE_DELAY:   equ 4

@GS_TRANSITION: 
    stateStruct enter,update


;-----------------------------------------------------------------------------------
;
; Macro TRANSITION_SCREEN
;
; IN : Game State to change to
;      Backdrop image to switch to when fading in
;
;-----------------------------------------------------------------------------------
    macro TRANSITION_SCREEN nextGS, backdrop
        ld hl,nextGS
        ld (GameState_Transition.nextGameState),hl
        ld a,backdrop/2
        ld (GameState_Transition.backGroundImageBank),a
        ld hl, GS_TRANSITION
        call GameStateMachine.change
    endm


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a, RECT_STATE_START
    ld (rectState),a
    
    ret


update:
    ld a,(rectState)
    ld hl, rectStateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl



rectStateJumpTable:
    dw stateRectStart
    dw stateRectIn
    dw stateRectOut
    dw stateRectDone
    dw stateRectDelay


;----STATE-----
;
stateRectStart:
    ld a, RECT_COUNT
    ld (rectCount),a
    ld a, RECT_STATE_IN
    ld (rectState),a
    ld hl,rectangles
    ld (rectPointer),hl
    ret

;----STATE-----
;
stateRectIn:
    ld a,(rectCount)
    or a 
    jr z, .nextState
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c, OPAQUE_TILE
    ld b, Tilemap.SOLID_BLACK
    call Print.rectangle
    ld de, RECT_LEN
    add ix, de
    ld (rectPointer),ix

    ld a, RECT_STATE_DELAY
    ld (rectState),a
    ld a, RECT_STATE_IN
    ld (rectNextState),a

    ret

.nextState:
    ld a, RECT_COUNT
    ld (rectCount),a
    ld a, RECT_STATE_OUT
    ld (rectState),a
    ld hl,rectangleLast
    ld (rectPointer),hl

    ;Swap to the new backdrop
    nextreg LAYER_2_CONTROL, %00010000
    ld a,(GameState_Transition.backGroundImageBank)
    nextreg LAYER_2_RAM_PAGE, a

    ret

;----STATE-----
;
stateRectOut:
    ld a,(rectCount)
    or a 
    jr z, .nextState
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c, TRANSPARENT_TILE
    ld b, Tilemap.RED
    call Print.rectangle

    ld hl,ix
    ld de, RECT_LEN
    or a
    sbc hl, de
    ld (rectPointer),hl

    ld a, RECT_STATE_DELAY
    ld (rectState),a
    ld a, RECT_STATE_OUT
    ld (rectNextState),a

    ret

.nextState:
    ld a, RECT_STATE_DONE
    ld (rectState),a
    ret
;
;----STATE-----
;
stateRectDone:
    ;Change to the next game state
    ld hl,(nextGameState)
    call GameStateMachine.change
    ret


stateRectDelay:
    ld a, (rectNextState)
    ld (rectState),a
    ret


;
;----STATE-----
;
updateRects:
    ld a,(rectCount)
    or a 
    ret z
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c,(ix+4)
    ld b, (ix+5)
    call Print.rectangle
    ld de, RECT_LEN
    add ix, de
    ld (rectPointer),ix

    ret

rectangles:
    db 0,0, 39,31, 20, Tilemap.RED
    db 1,1, 38,30, 21, Tilemap.BLUE
    db 2,2, 37,29, 22, Tilemap.BLUE
    db 3,3, 36,28, 23, Tilemap.RED
    db 4,4, 35,27, 24, Tilemap.BLUE
    db 5,5, 34,26, 25, Tilemap.RED
    db 6,6, 33,25, 26, Tilemap.BLUE
    db 7,7, 32,24, 27, Tilemap.RED
    db 8,8, 31,23, 28, Tilemap.BLUE
    db 9,9, 30,22, 29, Tilemap.RED
    db 10,10, 29,21, 30, Tilemap.BLUE
    db 11,11, 28,20, 31, Tilemap.RED
    db 12,12, 27,19, 32, Tilemap.BLUE
    db 13,13, 26,18, 33, Tilemap.RED
    db 14,14, 25,17, 34, Tilemap.BLUE
    db 15,15, 24,16, 35, Tilemap.RED
    db 16,15, 23,16, 36, Tilemap.BLUE
    db 17,15, 22,16, 37, Tilemap.RED
    db 18,15, 21,16, 38, Tilemap.BLUE
rectangleLast:
    db 19,15, 20,16, 39, Tilemap.RED

rectPointer:        dw rectangles
rectCount:          db RECT_COUNT
rectState:          db RECT_STATE_START
rectNextState:      db RECT_STATE_START


nextGameState           dw 0
backGroundImageBank     db 0


    endmodule