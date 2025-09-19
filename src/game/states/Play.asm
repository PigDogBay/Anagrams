;-----------------------------------------------------------------------------------
; 
; State: play
; 
; Player drags tiles
; 
;-----------------------------------------------------------------------------------

    module GameState_Play

STATE_TIME_NORMAL              equ 0
STATE_TIME_START_DEDUCT        equ 1
STATE_TIME_DEDUCT              equ 2

DEDUCTION_COUNTER_MAX          equ 5


@GS_PLAY:
    stateStruct enter,update


enter:
    call Tilemap.clear
    ;Set up callback when drag ends
    ld hl, dragEnd
    ld (PlayMouse.dragEndCallback),hl
    call printShortYearTerm
    call printCategory
    ret

update:
    call GamePhases.playUpdate
    jr z, gameOver
    call Game.updateMouse
    call PlayMouse.update
    call Game.updateSprites
    call timeUpdate
    call printTime
    ret

gameOver:
    STOP_ALL_ANIMATION
    ; next state
    ld hl, GS_GAME_OVER
    call GameStateMachine.change
    ret


;-----------------------------------------------------------------------------------
; Function: dragEnd(uint16 ptrSprite)
;
; Called when the mouse has stopped dragging a tile, checks if a a tile has been placed
; in a slot and then checks if the puzzle is solved. If the tile is placed over a slot
; that is occuppied, then the dragged tile is bounced away.
; 
; In: IX - dragged Tile Sprite 
; 
;-----------------------------------------------------------------------------------
dragEnd:
    ;Out:   A - 0 if not over slot
    ;       IX - tile sprite
    ;       IY - slot sprite
    call Board.isSelectedTileOverSlot
    or a
    ret z

    ;if slot is occupied bounce tile downwards
    call Board.placeTile
    or a
    jr nz, .slotOccuppied
    call Board.snapTileToSlot

    call Board.isSolved
    or a
    ret z
    ld hl, GS_SOLVED
    call GameStateMachine.change
    ret

.slotOccuppied:
    call Board.bounceTile
    ret




printTime:
    call Time.printToBuffer
    ld hl,Print.buffer
    ld d, 1
    ld e, 1
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString
    ret

printShortYearTerm:
    ld de, Print.buffer
    call YearTerm.printToBuffer
    ;Print the buffer to the screen
    ld hl,Print.buffer
    ld e, 1
    ld b,%00000000
    call Print.printCentred
    ret

printCategory:
    ld a, (Puzzles.category)
    call Puzzles.categoryToString
    ld e, 3
    ld b,%00000000
    call Print.printCentred
    ret



;-----------------------------------------------------------------------------------
; 
; Function: deduct(uint8 seconds)
;
; Subtracts the seconds from the current time
;
; In: A - Amount of time in seconds to deduct
;
; Dirty: DE
; 
;-----------------------------------------------------------------------------------
deductTime:
    ld (deductionAmount),a
    ld a,STATE_TIME_START_DEDUCT
    ld (deductionState),a
    ret


;-----------------------------------------------------------------------------------
;
; Time state machine, handles printing and deducting time
;
;-----------------------------------------------------------------------------------
timeUpdate:
    ld a, (deductionState)
    cp a,STATE_TIME_START_DEDUCT
    jr z, stateDeductInit
    cp a,STATE_TIME_DEDUCT
    jr z, stateDeduct
    ret

stateDeductInit:
    ld a, (deductionAmount)
    ld de,Print.buffer
    call Lifelines.printCost
    ld hl, Print.buffer
    ld d, 1
    ld e, 2
    call Print.setCursorPosition
    ld b,%00010000
    call Print.printString
    call Time.deduct

    ld a,STATE_TIME_DEDUCT
    ld (deductionState),a
    xor a
    ld (deductionCounter),a
    ret

stateDeduct:
    ld a,(deductionCounter)
    cp a, DEDUCTION_COUNTER_MAX
    jr z, .knockSecondOff
    inc a
    ld (deductionCounter),a
    ret

.knockSecondOff:
    xor a
    ld (deductionCounter),a
    ld a,1
    call Time.deduct
    ld a,(deductionAmount)
    dec a
    jr z, .finished
    ld (deductionAmount),a
    ret

.finished:
    ld e,2
    call Print.clearLine
    ld a,STATE_TIME_NORMAL
    ld (deductionState),a
    ret


deductionCounter:   db 0
deductionState:     db STATE_TIME_NORMAL
deductionAmount:    db 0

    endmodule