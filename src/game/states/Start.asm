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

LIFELINE_START_Y_POS    equ 60
LIFELINE_START_Y_STEP   equ 32


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
    ld b, LIFELINE_START_Y_POS
    ld a,(Lifelines.costTile)
    ld hl, lifeLine1Sprite
    call addSprite

    ld a,(Lifelines.costSlot)
    ld hl, lifeLine2Sprite
    call addSprite

    ld a,(Lifelines.costRand)
    ld hl, lifeLine3Sprite
    call addSprite

    ld a,(Lifelines.costClue)
    ld hl, lifeLine4Sprite
    call addSprite

    ld hl, quitSprite
    call SpriteList.addSprite
    ret

;Subroutine addButtons.addSprite
;
; Adds Sprite if A doesn't equal zero
; In:
;   A = life line cost
;   HL = spriteItem
;   B = Position
; Out:
;   B = Updated Position if sprite added
; Dirty A, IX
;
addSprite
    or a
    ret z
    ld ix,hl
    ld (ix + spriteItem.y),b
    call SpriteList.addSprite
    ; Move to next Y pos
    ld a,b
    add LIFELINE_START_Y_STEP
    ld b,a
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