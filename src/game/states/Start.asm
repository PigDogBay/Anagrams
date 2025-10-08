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
    call Tilemap.clear
    ld a,(YearTerm.term)
    cp 1
    jr nz, .year2
    L2_SET_IMAGE IMAGE_MICHAELMAS
    jr .doneImage
.year2:
    cp 2
    jr nz, .year3
    L2_SET_IMAGE IMAGE_HILARY
    jr .doneImage
.year3:
    L2_SET_IMAGE IMAGE_TRINITY
.doneImage:

    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call addButtons

    call GamePhases.playStart

    ret

update:
    ; next state
    ld hl, GS_PLAY
    call GameStateMachine.change

    ret

addButtons:
    ld a,(Lifelines.costTile)
    or a
    jr z, .next1
    ld hl, lifeLine1Sprite
    call SpriteList.addSprite

.next1
    ld a,(Lifelines.costSlot)
    or a
    jr z, .next2
    ld hl, lifeLine2Sprite
    call SpriteList.addSprite

.next2
    ld a,(Lifelines.costRand)
    or a
    jr z, .next3
    ld hl, lifeLine3Sprite
    call SpriteList.addSprite

.next3
    ld a,(Lifelines.costClue)
    or a
    jr z, .next4
    ld hl, lifeLine4Sprite
    call SpriteList.addSprite

.next4:
    ld hl, quitSprite
    call SpriteList.addSprite
    ret

lifeLine1Sprite:
    spriteItem 0, 4, 48, 0, Sprites.CALCULATOR | SPRITE_VISIBILITY_MASK, LIFELINE_1_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine2Sprite:
    spriteItem 0, 4, 72, 0, Sprites.TAO | SPRITE_VISIBILITY_MASK, LIFELINE_2_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine3Sprite:
    spriteItem 0, 4, 96, 0, Sprites.BEER | SPRITE_VISIBILITY_MASK, LIFELINE_3_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
lifeLine4Sprite:
    spriteItem 0, 4, 120, 0, Sprites.NOTEPAD | SPRITE_VISIBILITY_MASK, LIFELINE_4_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
quitSprite:
    spriteItem 0, 300, 4, 0, Sprites.QUIT_BUTTON | SPRITE_VISIBILITY_MASK, QUIT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE




    endmodule