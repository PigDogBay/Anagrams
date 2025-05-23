    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Mouse

    macro UPDATE_STATE spriteId, buttons, currentState, expectedState
        ld a, buttons
        ld (mouse.buttons), a
        ld a, currentState
        ld (mouse.state), a
        ld a, spriteId
        call mouse.updateState
        TEST_MEMORY_BYTE mouse.state, expectedState
    endm

NOT_PRESSED: equ $ff
PRESSED: equ $00

; Not over sprite, no press, expect stay in ready state
UT_ready1:
    UPDATE_STATE 0, NOT_PRESSED, mouse.STATE_READY, mouse.STATE_READY
    TC_END

; Mouse over, no press, expect state to change to hover
UT_ready2:
    UPDATE_STATE 42, NOT_PRESSED, mouse.STATE_READY, mouse.STATE_HOVER
    TC_END

; Mouse not over a sprite, pressed, expect state to change to pressed
UT_ready3:
    UPDATE_STATE 0, PRESSED, mouse.STATE_READY, mouse.STATE_PRESSED
    TC_END

; Mouse over a sprite, pressed, expect DRAG_START
UT_read4:
    UPDATE_STATE 8, PRESSED, mouse.STATE_READY, mouse.STATE_DRAG_START
    TC_END

; If still pressed stay pressed
UT_pressed1:
    UPDATE_STATE 8, PRESSED, mouse.STATE_PRESSED, mouse.STATE_PRESSED
    TC_END

; If stopped pressing pressed->ready
UT_pressed2:
    UPDATE_STATE 0, NOT_PRESSED, mouse.STATE_PRESSED, mouse.STATE_READY
    TC_END

; Mouse over (assumed if dragging), pressed, expect DRAG_START->DRAG
UT_dragStart1:
    UPDATE_STATE 0, PRESSED, mouse.STATE_DRAG_START, mouse.STATE_DRAG
    TC_END

; Mouse over (assumed if dragging), not pressed, expect DRAG_START->DRAG_END
UT_dragStart2:
    UPDATE_STATE 0, NOT_PRESSED, mouse.STATE_DRAG_START, mouse.STATE_DRAG_END
    TC_END

; Mouse over (assumed if dragging), pressed, expect DRAG->DRAG
UT_drag1:
    UPDATE_STATE 8, PRESSED, mouse.STATE_DRAG, mouse.STATE_DRAG
    TC_END

; Mouse over (assumed if dragging), not pressed, expect DRAG->DRAG_END
UT_drag2:
    UPDATE_STATE 8, NOT_PRESSED, mouse.STATE_DRAG, mouse.STATE_DRAG_END
    TC_END

; This state exists to notify client that dragging has stop
; not affected by inputs
; expect DRAG_END->READY
UT_dragEnd1:
    UPDATE_STATE 8, NOT_PRESSED, mouse.STATE_DRAG_END, mouse.STATE_READY
    TC_END

    endmodule
