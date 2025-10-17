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

;    call drawAllRects
    ret

; Old code

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
     call rectStateUpdate
    ; next state
;    ld hl, GS_PUZZLE_VIEWER
    ; ld hl,$0201
    ; call YearTerm.select
    ;  ld hl, GS_WIN
    ;  call GameStateMachine.change
    ret


RECT_LEN            equ 6
RECT_COUNT          equ 20
rectPointer:        dw rectangles
rectCount:          db RECT_COUNT
rectState:          db RECT_STATE_START

RECT_STATE_START:   equ 0
RECT_STATE_IN:      equ 1
RECT_STATE_OUT:     equ 2
RECT_STATE_DONE:    equ 3
TRANSPARENT_TILE:   equ 0
OPAQUE_TILE:        equ 97

rectStateJumpTable:
    dw stateRectStart
    dw stateRectIn
    dw stateRectOut
    dw stateRectDone

rectStateUpdate:
    ld a,(rectState)
    ld hl, rectStateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl

;----STATE-----
;
stateRectStart:
    ld a, RECT_COUNT
    ld (rectCount),a
    ld a, RECT_STATE_IN
    ld (rectState),a
    ld hl,rectangles
    ld (rectPointer),hl
    ret

;----STATE-----
;
stateRectIn:
    ld a,(rectCount)
    or a 
    jr z, .nextState
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c, OPAQUE_TILE
    ld b, Tilemap.SOLID_BLACK
    call Print.rectangle
    ld de, RECT_LEN
    add ix, de
    ld (rectPointer),ix

    ret

.nextState:
    ld a, RECT_COUNT
    ld (rectCount),a
    ld a, RECT_STATE_OUT
    ld (rectState),a
    ld hl,rectangleLast
    ld (rectPointer),hl

    ret

;----STATE-----
;
stateRectOut:
    ld a,(rectCount)
    or a 
    jr z, .nextState
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c, TRANSPARENT_TILE
    ld b, Tilemap.RED
    call Print.rectangle

    ld hl,ix
    ld de, RECT_LEN
    or a
    sbc hl, de
    ld (rectPointer),hl
    ret

.nextState:
    ld a, RECT_STATE_DONE
    ld (rectState),a
    ret
;
;----STATE-----
;
stateRectDone:
    ld a, RECT_STATE_START
    ld (rectState),a
    ret


updateRects:
    ld a,(rectCount)
    or a 
    ret z
    dec a
    ld (rectCount),a

    ld ix,(rectPointer)
    ld c,(ix+4)
    ld b, (ix+5)
    call Print.rectangle
    ld de, RECT_LEN
    add ix, de
    ld (rectPointer),ix

    ret

drawAllRects:
    ld a,RECT_COUNT
    ld ix,rectangles
    ld de, RECT_LEN
.loop
    ld c,(ix+4)
    ld b, (ix+5)
    call Print.rectangle
    add ix, de
    dec a
    jr nz, .loop
    ret
rectangles:
    db 0,0, 39,31, 20, Tilemap.RED
    db 1,1, 38,30, 21, Tilemap.BLUE
    db 2,2, 37,29, 22, Tilemap.BLUE
    db 3,3, 36,28, 23, Tilemap.RED
    db 4,4, 35,27, 24, Tilemap.BLUE
    db 5,5, 34,26, 25, Tilemap.RED
    db 6,6, 33,25, 26, Tilemap.BLUE
    db 7,7, 32,24, 27, Tilemap.RED
    db 8,8, 31,23, 28, Tilemap.BLUE
    db 9,9, 30,22, 29, Tilemap.RED
    db 10,10, 29,21, 30, Tilemap.BLUE
    db 11,11, 28,20, 31, Tilemap.RED
    db 12,12, 27,19, 32, Tilemap.BLUE
    db 13,13, 26,18, 33, Tilemap.RED
    db 14,14, 25,17, 34, Tilemap.BLUE
    db 15,15, 24,16, 35, Tilemap.RED
    db 16,15, 23,16, 36, Tilemap.BLUE
    db 17,15, 22,16, 37, Tilemap.RED
    db 18,15, 21,16, 38, Tilemap.BLUE
rectangleLast:
    db 19,15, 20,16, 39, Tilemap.RED





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