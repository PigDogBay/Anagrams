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
    call printColoredText
  ret



update:
     call Game.updateMouse
     call Game.updateSprites
    ; next state
;    ld hl, GS_PUZZLE_VIEWER
    ; ld hl,$0201
    ; call YearTerm.select
    ; ld hl, GS_GAME_OVER
    ; call GameStateMachine.change
    ret

printColoredText:
    ld hl,text5B
    ld b,Tilemap.RED
    ld e, 5
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.BLUE
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.GREEN
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.YELLOW
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.TEAL
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.PURPLE
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.GOLD
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.WHITE
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.LIGHT_BLUE
    inc e : inc e
    call Print.printCentred

    ld hl,text5B
    ld b,Tilemap.DESERT
    inc e : inc e
    call Print.printCentred

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

text5B db 127," MPD BAILEY TECHNOLOGY",0

lifeLine1Sprite:
    spriteItem 0, 4, 48, 0, Sprites.EYE | SPRITE_VISIBILITY_MASK, LIFELINE_1_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine2Sprite:
    spriteItem 0, 4, 72, 0, Sprites.APPLE | SPRITE_VISIBILITY_MASK, LIFELINE_2_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine3Sprite:
    spriteItem 0, 4, 96, 0, Sprites.TUTOR | SPRITE_VISIBILITY_MASK, LIFELINE_3_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine4Sprite:
    spriteItem 0, 4, 120, 0, Sprites.TAO | SPRITE_VISIBILITY_MASK, LIFELINE_4_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
quitSprite:
    spriteItem 0, 300, 4, 0, Sprites.QUIT_BUTTON | SPRITE_VISIBILITY_MASK, QUIT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE


    endmodule