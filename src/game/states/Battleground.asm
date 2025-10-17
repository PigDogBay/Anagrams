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
    ;call printColoredText
    ; Function: horizontalLine(uint8 x1 : d, uint8 y1 : e, uint8 x2 : h, uint8 tile : c, uint8 attr : b) 
    ld d,5 : ld e,16 : ld h, 5 : ld c, 19 : ld b, Tilemap.PURPLE
    call Print.horizontalLine
    ; Function: verticalLine(uint8 x : D, uint8 y1 : E, uint8 y2 : H, uint8 tile : C, uint8 attr : B) 
    ld d,16 : ld e,10 : ld h, 10 : ld c, 18 : ld b, Tilemap.DESERT
    call Print.verticalLine
    ld ix,.rect1 : ld c,(ix+4) : ld b, (ix+5)
    call Print.rectangle
    ld ix,.rect2 : ld c,(ix+4) : ld b, (ix+5)
    call Print.rectangle
    ld ix,.rect3 : ld c,(ix+4) : ld b, (ix+5)
    call Print.rectangle
    ld ix,.rect4 : ld c,(ix+4) : ld b, (ix+5)
    call Print.rectangle

  ret
.rect1:
    db 0,0,39,31,20, Tilemap.RED
.rect2:
    db 1,1,38,30,21, Tilemap.GREEN
.rect3:
    db 20,16,20,16,22, Tilemap.BLUE
.rect4:
    db 19,15,21,17,23, Tilemap.YELLOW


update:
     call Game.updateMouse
     call Game.updateSprites
    ; next state
;    ld hl, GS_PUZZLE_VIEWER
    ; ld hl,$0201
    ; call YearTerm.select
    ;  ld hl, GS_WIN
    ;  call GameStateMachine.change
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