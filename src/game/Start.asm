;-----------------------------------------------------------------------------------
; 
; State: start
; 
; Initializes the game
; 
;-----------------------------------------------------------------------------------
    module GameState_Start

@GS_START: 
    stateStruct enter,update


enter:
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Slot.removeAll
    call Tile.removeAll
    ld hl,Game.anagram
    ;TODO, start game ID at 16 for tiles and slots, need better management of this
    ld c, 16
    call Slot.createSlots
    ld hl,Game.anagram
    ; Randomize letters
    call String.shuffle
    call Tile.createTiles
    call Tile.tilesToSprites
    call Slot.slotsToSprites
    ret

update:
    ; next state
    ld hl, GS_PLAY
    call GameStateMachine.change

    ret


    endmodule