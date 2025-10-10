;-----------------------------------------------------------------------------------
; 
; State: Level Select
; 
; Choose the level to play
; 
;-----------------------------------------------------------------------------------

    module GameState_Prospectus

@GS_PROSPECTUS: 
    stateStruct enter,update

TITLE_Y             equ 22
LIFELINE_X_POS      equ 104
LIFELINE_X_STEP     equ 32
LIFELINE_Y_POS      equ 168
BUTTONS_Y           equ 116
TOOL_TIP_LINE1      equ 25

enter:
    L2_SET_IMAGE IMAGE_PROSPECTUS
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer


    ;Animated Sprite Tile
    ;Add slots and amke SYLLABUS tiles appear

    ld bc, spriteLen
    ld de, SpriteList.count
    ld hl, spriteData
    ldir
    call Visibility.removeAll
    ;B - gameId, C - delay
    ld b, 21 : ld c, 14 : call Visibility.add
    ld b, 22 : ld c, 18: call Visibility.add
    ld b, 23 : ld c, 22 : call Visibility.add
    ld b, 24 : ld c, 26 : call Visibility.add
    ld b, 25 : ld c, 30 : call Visibility.add
    ld b, 26 : ld c, 34 : call Visibility.add
    ld b, 27 : ld c, 38 : call Visibility.add
    ld b, 28 : ld c, 42 : call Visibility.add
    ld b, 29 : ld c, 46 : call Visibility.add
    ld b, 30 : ld c, 50 : call Visibility.add
    call Visibility.start
    call showLifelines
    call Sound.playStartMusic
    jp printText


update:
    ;Shake RNG
    call Maths.getRandom
    call Game.updateMouse
    call mouseStateHandler
    call Game.updateSprites
    ret


jumpTable:
    dw stateMouseReady
    dw stateMouseHover
    dw stateMouseHoverEnd
    dw stateMousePressed
    dw stateMouseClicked
    dw stateMouseDragStart
    dw stateMouseDrag
    dw stateMouseDragOutOfBounds
    dw stateMouseDragEnd
    dw stateMouseClickedOff
    dw stateMouseBackgroundPressed
    dw stateMouseBackgroundClicked

;-----------------------------------------------------------------------------------
;
; Function: mouseStateHandler
;
; Updates the game based on the current mouse state 
; In - A current mouse state
;    - IX pointer to sprite that mouse is over
;-----------------------------------------------------------------------------------
mouseStateHandler:
    ld hl, jumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl

stateMouseReady:
    ret
stateMouseHover:
    ld a,c
    cp LIFELINE_1_BUTTON
    ld hl, Lifelines.tip1
    jp z, printTipLifeLine

    cp LIFELINE_2_BUTTON
    ld hl, Lifelines.tip2
    jp z, printTipLifeLine

    cp LIFELINE_3_BUTTON
    ld hl, Lifelines.tip3
    jp z, printTipLifeLine

    cp LIFELINE_4_BUTTON
    ld hl, Lifelines.tip4
    jp z, printTipLifeLine
    ret

stateMouseHoverEnd:
    ld e, TOOL_TIP_LINE1
    call Print.clearLine
    ret
stateMousePressed:
stateMouseDrag:
stateMouseDragOutOfBounds:
stateMouseDragEnd:
stateMouseClickedOff:
stateMouseBackgroundPressed:
stateMouseDragStart:
    ret

stateMouseBackgroundClicked:
    call GamePhases.start
    ;Skip first round screen, so need to call roundStart here
    call GamePhases.roundStart
    
    STOP_ALL_ANIMATION
    ld hl, GS_START
    call GameStateMachine.change
    ret

stateMouseClicked:
    ld a,c
    cp PREVIOUS_BUTTON
    jr z, previousClicked
    cp NEXT_BUTTON
    jr z, nextClicked
    ret


previousClicked:
    call College.previousCollege
    call showLifelines
    call Sound.buttonClicked
    jp printText


nextClicked:
    call College.nextCollege
    call showLifelines
    call Sound.buttonClicked
    jp printText



printText:
    call Tilemap.clear
    ld e, 6
    ld hl,universityText
    ld b,Tilemap.DESERT
    call Print.printCentred

    ;Choose instruction
    ld e, 12
    ld hl,settingsInstruction
    ld b,Tilemap.LIGHT_BLUE
    call Print.printCentred

    ld e, 15
    call College.getCollegeName
    ld b,Tilemap.TEAL
    call Print.printCentred

    ;Print game settings
    call College.getCollegeStruct
    ld ix,hl
    ld hl, (ix + collegeStruct.startTime)
    ld de,Print.buffer
    call Print.bufferPrintNumber

    ld a, (ix + collegeStruct.timePerYear)
    ld hl, settingsSeparator
    call Lifelines.printCost
    
    ld hl, settingsSuffix
    call Print.bufferPrint

    ld e, 18
    ld b,Tilemap.YELLOW
    ld hl,Print.buffer
    call Print.printCentred

    ; Click to continue
    ld e, 29
    ld hl,startInstruction
    ld b,Tilemap.GREEN
    call Print.printCentred
    ret

printTipLifeLine:
    ld e, TOOL_TIP_LINE1
    ld b,Tilemap.WHITE
    call Print.printCentred
    ret


showLifelines:
    call College.getCollegeStruct
    ld ix,hl

    ld b, (ix + collegeStruct.lifeLineCost1)
    ld a, LIFELINE_1_BUTTON
    call setVisibility

    ld b, (ix + collegeStruct.lifeLineCost2)
    ld a, LIFELINE_2_BUTTON
    call setVisibility

    ld b, (ix + collegeStruct.lifeLineCost3)
    ld a, LIFELINE_3_BUTTON
    call setVisibility

    ld b, (ix + collegeStruct.lifeLineCost4)
    ld a, LIFELINE_4_BUTTON
    call setVisibility
    ret

;Subroutine addLifeLines.setVisibility
;
; Adds Sprite if A doesn't equal zero
; In:
;   A = game ID
;   B = life line cost
; Dirty A, IY
;
setVisibility
    call SpriteList.find
    ld a,b
    ld iy,hl
    or a
    ld a,(iy + spriteItem.pattern)
    jr nz, .visible
    res BIT_SPRITE_VISIBLE,a
    ld (iy + spriteItem.pattern),a
    ret

.visible:
    or SPRITE_VISIBILITY_MASK
    ld (iy + spriteItem.pattern),a
    ret


universityText:
    db "UNIVERSITY OF OXBRIDGE",0

settingsInstruction:
    db "CHOOSE YOUR COLLEGE",0

settingsSeparator:
    db "s / -",0
settingsSuffix:
    db " PER YEAR",0


startInstruction:
    db "CLICK TO ENROL",0


spriteData:
    db 17
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,61,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,21,0
    spriteItem 2,81,TITLE_Y,0, 'R'-Tile.ASCII_PATTERN_OFFSET,22,0
    spriteItem 3,101,TITLE_Y,0,'O'-Tile.ASCII_PATTERN_OFFSET,23,0
    spriteItem 4,121,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,24,0
    spriteItem 5,141,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,25,0
    spriteItem 6,161,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,26,0
    spriteItem 7,181,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,27,0
    spriteItem 8,201,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,28,0
    spriteItem 9,221,TITLE_Y,0,'U'-Tile.ASCII_PATTERN_OFFSET,29,0
    spriteItem 10,241,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,30,0
previousSprite:
    spriteItem 11, 60, BUTTONS_Y, 0, Sprites.PREVIOUS | SPRITE_VISIBILITY_MASK, PREVIOUS_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
nextSprite:
    spriteItem 12, 246, BUTTONS_Y, 0, Sprites.NEXT | SPRITE_VISIBILITY_MASK, NEXT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
;Add these sprites one at a time, depending on the college
lifeLine1Sprite:
    spriteItem 13, LIFELINE_X_POS, LIFELINE_Y_POS, 0, Sprites.CALCULATOR, LIFELINE_1_BUTTON, MouseDriver.MASK_HOVERABLE
lifeLine2Sprite:
    spriteItem 14, LIFELINE_X_POS + LIFELINE_X_STEP, LIFELINE_Y_POS, 0, Sprites.TAO, LIFELINE_2_BUTTON, MouseDriver.MASK_HOVERABLE
lifeLine3Sprite:
    spriteItem 15, LIFELINE_X_POS + LIFELINE_X_STEP * 2, LIFELINE_Y_POS, 0, Sprites.BEER, LIFELINE_3_BUTTON, MouseDriver.MASK_HOVERABLE
lifeLine4Sprite:
    spriteItem 16, LIFELINE_X_POS + LIFELINE_X_STEP * 3, LIFELINE_Y_POS, 0, Sprites.NOTEPAD, LIFELINE_4_BUTTON, MouseDriver.MASK_HOVERABLE

spriteLen: equ $ - spriteData


    endmodule