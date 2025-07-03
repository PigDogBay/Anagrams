    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_MouseDriver

    macro UPDATE_STATE flags, id, buttons, currentState, expectedState
        ld a, buttons
        ld (MouseDriver.buttons), a
        ld a, currentState
        ld (MouseDriver.state), a
        ld a, flags
        ld c, id
        call MouseDriver.updateState
        TEST_MEMORY_BYTE MouseDriver.state, expectedState
    endm

NOT_PRESSED: equ $ff
PRESSED: equ $00

ID_BG: equ 0
ID_DRAGGABLE: equ 42
ID_CLICKABLE: equ 80
ID_CLICKABLE_OTHER: equ 90
ID_HOVERABLE: equ 81


; Not over sprite, no press, expect stay in ready state
UT_ready1:
    UPDATE_STATE 0,ID_BG, NOT_PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_READY
    TC_END

; Mouse over, no press, expect state to change to hover
UT_ready2:
    UPDATE_STATE 42, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_HOVER
    TC_END

; Mouse not over a sprite, pressed, expect state to change to BACKGROUND_PRESSED
UT_ready3:
    UPDATE_STATE 0,ID_BG, PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_BACKGROUND_PRESSED
    TC_END

; Mouse over a sprite, pressed, expect DRAG_START
UT_ready4:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_DRAG_START
    TC_END

; Mouse over a clickable sprite, pressed, expect PRESSED
UT_ready5:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE | MouseDriver.MASK_HOVERABLE, ID_CLICKABLE, PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_PRESSED
    TC_END


; Mouse over a sprite, not pressed, expect HOVER
UT_hover1:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_HOVER
    TC_END

; Mouse over a sprite, not pressed, expect to stay in HOVER
UT_hover2:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_HOVER, MouseDriver.STATE_HOVER
    TC_END

; Mouse not over a sprite, not pressed, expect to hover_end
UT_hover3:
    UPDATE_STATE 0,ID_BG, NOT_PRESSED, MouseDriver.STATE_HOVER, MouseDriver.STATE_HOVER_END
    TC_END

; Mouse over a sprite, pressed, expect DRAG_START
UT_hover4:
    UPDATE_STATE MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, PRESSED, MouseDriver.STATE_HOVER, MouseDriver.STATE_DRAG_START
    TC_END

; Mouse over a sprite, pressed, but not draggable or clickable, expect STATE_BACKGROUND_PRESSED
UT_hover5:
    UPDATE_STATE MouseDriver.MASK_HOVERABLE, ID_HOVERABLE, PRESSED, MouseDriver.STATE_HOVER, MouseDriver.STATE_BACKGROUND_PRESSED
    TC_END

; Mouse over a clickable sprite, pressed, expect PRESSED
UT_hover6:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE | MouseDriver.MASK_HOVERABLE, ID_CLICKABLE, PRESSED, MouseDriver.STATE_HOVER, MouseDriver.STATE_PRESSED
    TC_END


; Expect to return to READY, whatever mouse is doing
UT_hover_end1:
    UPDATE_STATE 0, ID_BG, NOT_PRESSED, MouseDriver.STATE_HOVER_END, MouseDriver.STATE_READY
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, PRESSED, ID_CLICKABLE, MouseDriver.STATE_HOVER_END, MouseDriver.STATE_READY
    TC_END

UT_bg_pressed1:
    UPDATE_STATE  0, ID_BG, PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_BACKGROUND_PRESSED
    TC_END

; If still pressed stay pressed
UT_bg_pressed2:
    UPDATE_STATE  0, ID_BG, PRESSED, MouseDriver.STATE_BACKGROUND_PRESSED, MouseDriver.STATE_BACKGROUND_PRESSED
    TC_END

; If stopped pressing pressed->clicked
UT_bg_clicked1:
    UPDATE_STATE  0, ID_BG, NOT_PRESSED, MouseDriver.STATE_BACKGROUND_PRESSED, MouseDriver.STATE_BACKGROUND_CLICKED
    TC_END


UT_pressed1:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE, ID_CLICKABLE, PRESSED, MouseDriver.STATE_READY, MouseDriver.STATE_PRESSED
    TC_END

; If still pressed stay pressed
UT_pressed2:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE, ID_CLICKABLE, PRESSED, MouseDriver.STATE_PRESSED, MouseDriver.STATE_PRESSED
    TC_END

; If stopped pressing pressed->ready
UT_clicked1:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE, ID_CLICKABLE, NOT_PRESSED, MouseDriver.STATE_PRESSED, MouseDriver.STATE_CLICKED
    TC_END

; Mouse has stopped pressing, but has been dragged off the sprite whilst pressing, expect clicked_off
UT_clicked_off1:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE, ID_BG, NOT_PRESSED, MouseDriver.STATE_PRESSED, MouseDriver.STATE_CLICKED_OFF
    TC_END

; Mouse has stopped pressing, but has been dragged off onto another sprite whilst pressing, expect clicked_off
UT_clicked_off2:
    UPDATE_STATE  MouseDriver.MASK_CLICKABLE, ID_CLICKABLE_OTHER, NOT_PRESSED, MouseDriver.STATE_PRESSED, MouseDriver.STATE_CLICKED_OFF
    TC_END

; Mouse over (assumed if dragging), pressed, expect DRAG_START->DRAG
UT_dragStart1:
    UPDATE_STATE MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, PRESSED, MouseDriver.STATE_DRAG_START, MouseDriver.STATE_DRAG
    TC_END

; Mouse over (assumed if dragging), not pressed, expect DRAG_START->DRAG_END
UT_dragStart2:
    UPDATE_STATE MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_DRAG_START, MouseDriver.STATE_DRAG_END
    TC_END

; Mouse over (assumed if dragging), pressed, expect DRAG->DRAG
UT_drag1:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, PRESSED, MouseDriver.STATE_DRAG, MouseDriver.STATE_DRAG
    TC_END

; Mouse over (assumed if dragging), not pressed, expect DRAG->DRAG_END
UT_drag2:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE,  ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_DRAG, MouseDriver.STATE_DRAG_END
    TC_END

; This state exists to notify client that dragging has stop
; not affected by inputs
; expect DRAG_END->READY
UT_dragEnd1:
    UPDATE_STATE  MouseDriver.MASK_DRAGABLE | MouseDriver.MASK_HOVERABLE, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_DRAG_END, MouseDriver.STATE_READY
    TC_END

UT_dragOutOfBounds1:
    ld a, MouseDriver.STATE_DRAG
    ld (MouseDriver.state), a
    call MouseDriver.dragOutOfBounds
    TEST_MEMORY_BYTE MouseDriver.state, MouseDriver.STATE_DRAG_OUT_OF_BOUNDS
    TC_END

; Only go into out of bounds if currently in DRAG_STATE
UT_dragOutOfBounds2:
    ld a, MouseDriver.STATE_READY
    ld (MouseDriver.state), a
    call MouseDriver.dragOutOfBounds
    TEST_MEMORY_BYTE MouseDriver.state, MouseDriver.STATE_READY
    TC_END

;Test that state exits only when button is released
UT_stateDragOutOfBounds1:
    UPDATE_STATE 8, ID_DRAGGABLE, PRESSED, MouseDriver.STATE_DRAG_OUT_OF_BOUNDS, MouseDriver.STATE_DRAG_OUT_OF_BOUNDS
    UPDATE_STATE 8, ID_DRAGGABLE, NOT_PRESSED, MouseDriver.STATE_DRAG_OUT_OF_BOUNDS, MouseDriver.STATE_READY

    endmodule
