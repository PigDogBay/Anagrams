;-----------------------------------------------------------------------------------
; 
; State: Battleground
; 
; Test state for trying out code
; 
;-----------------------------------------------------------------------------------

    module GameState_Battleground

@GS_BATTLEGROUND: 
    stateStruct enter,update


enter:
    L2_SET_IMAGE IMAGE_MICHAELMAS
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call addButtons
  ret



update:
    call Game.updateMouse
    call Game.updateSprites
;     ; next state
;     ld hl, GS_PUZZLE_VIEWER
; ;    ld hl, GS_WIN
;     call GameStateMachine.change
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
    spriteItem 0, 4, 48, 0, Sprites.PREVIOUS | SPRITE_VISIBILITY_MASK, LIFELINE_1_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine2Sprite:
    spriteItem 0, 4, 72, 0, Sprites.NEXT | SPRITE_VISIBILITY_MASK, LIFELINE_2_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine3Sprite:
    spriteItem 0, 4, 96, 0, 10 | SPRITE_VISIBILITY_MASK, LIFELINE_3_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine4Sprite:
    spriteItem 0, 4, 120, 0, 11 | SPRITE_VISIBILITY_MASK, LIFELINE_4_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
quitSprite:
    spriteItem 0, 300, 4, 0, Sprites.QUIT_BUTTON | SPRITE_VISIBILITY_MASK, QUIT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE


    endmodule