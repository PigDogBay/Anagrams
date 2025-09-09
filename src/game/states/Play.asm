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
    call printMoney
    ret

update:
    call Game.updateMouse
    call PlayMouse.update
    call Game.updateSprites
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


printMoney:
    ld hl, Print.buffer
    ld (hl), 96  ; £ symbol
    inc hl
    ex de,hl

    ld hl,(Puzzles.money)
    ld a,1
    call ScoresConvert.ConvertToDecimal

    ;Append extra 0 and null terminator
    ex de,hl
    add hl,a
    ld (hl),'0'
    inc hl
    ld (hl),0

    ;Print the buffer to the screen
    ld hl,Print.buffer
    ld d, 0
    ld e, 0
    call Print.setCursorPosition
    ld b,%00000000
    call Print.printString

    ret


    endmodule