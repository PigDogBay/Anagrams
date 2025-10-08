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

TITLE_Y equ 30

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
    ld b, 1 : ld c, 14 : call Visibility.add
    ld b, 2 : ld c, 18: call Visibility.add
    ld b, 3 : ld c, 22 : call Visibility.add
    ld b, 4 : ld c, 26 : call Visibility.add
    ld b, 5 : ld c, 30 : call Visibility.add
    ld b, 6 : ld c, 34 : call Visibility.add
    ld b, 7 : ld c, 38 : call Visibility.add
    ld b, 8 : ld c, 42 : call Visibility.add
    ld b, 9 : ld c, 46 : call Visibility.add
    ld b, 10 : ld c, 50 : call Visibility.add
    ld b, 11 : ld c, 55 : call Visibility.add
    ld b, 12 : ld c, 55 : call Visibility.add
    call Visibility.start
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
stateMouseHover:
stateMouseHoverEnd:
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
    jp printText


nextClicked:
    call College.nextCollege
    jp printText



printText:
    call Tilemap.clear
    ld e, 7
    ld hl,universityText
    ld b,%00000000
    call Print.printCentred

    ;Choose instruction
    ld e, 12
    ld hl,settingsInstruction
    ld b,%00000000
    call Print.printCentred

    ld e, 16
    call College.getCollegeName
    ld b,%00000000
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

    ld e, 19
    ld b,%00010000
    ld hl,Print.buffer
    call Print.printCentred

    ; Click to continue
    ld e, 29
    ld hl,startInstruction
    ld b,%00010000
    call Print.printCentred
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
    db 13
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,61,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,81,TITLE_Y,0, 'R'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,101,TITLE_Y,0,'O'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,121,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,141,TITLE_Y,0,'P'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,161,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,181,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,201,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,221,TITLE_Y,0,'U'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,241,TITLE_Y,0,'S'-Tile.ASCII_PATTERN_OFFSET,10,0
previousSprite:
    spriteItem 11, 60, 124, 0, Sprites.PREVIOUS | SPRITE_VISIBILITY_MASK, PREVIOUS_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE
nextSprite:
    spriteItem 12, 246, 124, 0, Sprites.NEXT | SPRITE_VISIBILITY_MASK, NEXT_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

spriteLen: equ $ - spriteData

    endmodule