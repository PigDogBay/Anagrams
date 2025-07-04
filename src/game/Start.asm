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
    ld a,4
    call Graphics.fillLayer2_320

    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Slot.removeAll
    call Tile.removeAll

    call GameId.reset

    ld hl,Game.anagram
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