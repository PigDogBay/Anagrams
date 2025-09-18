;-----------------------------------------------------------------------------------
; 
; State: play
; 
; Player drags tiles
; 
;-----------------------------------------------------------------------------------

    module GameState_Play

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
    jr z, .gameOver
    call Game.updateMouse
    call PlayMouse.update
    call Game.updateSprites
    call printTime
    ret

.gameOver:
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


    endmodule