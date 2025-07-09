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

    call addButtons

    call Slot.removeAll
    call Tile.removeAll

    call GameId.reset

    call Puzzles.getAnagram
    call Slot.createSlots
    call Puzzles.jumbleLetters

    call Tile.createTiles
    call Tile.tilesToSprites
    call Slot.slotsToSprites
    ret

update:
    ; next state
    ld hl, GS_PLAY
    call GameStateMachine.change

    ret

addButtons:
    ld hl, lifeLine1Sprite
    call SpriteList.addSprite
    ld hl, lifeLine2Sprite
    call SpriteList.addSprite
    ld hl, lifeLine3Sprite
    call SpriteList.addSprite
    ld hl, lifeLine4Sprite
    call SpriteList.addSprite

    ld hl, quitSprite
    call SpriteList.addSprite
    ret



lifeLine1Sprite:
    spriteItem 0, 4, 48, 0, 8, LIFELINE_1_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine2Sprite:
    spriteItem 0, 4, 72, 0, 9, LIFELINE_2_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine3Sprite:
    spriteItem 0, 4, 96, 0, 10, LIFELINE_3_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine4Sprite:
    spriteItem 0, 4, 120, 0, 11, LIFELINE_4_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
quitSprite:
    spriteItem 0, 300, 4, 0, 24, QUIT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE




    endmodule