;-----------------------------------------------------------------------------------
; 
; State: Round
; 
; Displays information about the current level, round and upcoming puzzle
; 
;-----------------------------------------------------------------------------------

    module GameState_Round

@GS_ROUND: 
    stateStruct enter,update

TITLE_Y         equ 30
TITLE_Y2        equ 50
REROLL_X        equ 220
REROLL_Y        equ 172
TOOL_TIP_Y      equ 25
TOOL_TIP_X      equ 23

enter:
    L2_SET_IMAGE IMAGE_ROUND
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call RoundVM.init

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
    ld b, 31 : ld c, 54 : call Visibility.add
    ld b, 32 : ld c, 58 : call Visibility.add
    ld b, 33 : ld c, 62 : call Visibility.add
    call Visibility.start
    call Sound.playSolvedMusic

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
    cp REROLL_BUTTON
    jp z, printRerollTip
    ret

stateMouseHoverEnd:
    ld e, TOOL_TIP_Y
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
    ld hl, GS_START
    STOP_ALL_ANIMATION
    call GameStateMachine.change
    ret

stateMouseClicked:
    ld a,c
    cp REROLL_BUTTON
    jr z, onRerollClicked
    ret

.mousePressed:
    ret

onRerollClicked:
    call RoundVM.onRerollClick
    or a
    jr z, .noReroll
    ;Reprint text
    call printText
    call Sound.buttonClicked
    ret

.noReroll:
    call Sound.error
    ret

;-----------------------------------------------------------------------------------
;  
;-----------------------------------------------------------------------------------
printRerollTip:
    ;Create the string to print
    call RoundVM.printRerollTip

    ld d, TOOL_TIP_X
    ld e, TOOL_TIP_Y
    call Print.setCursorPosition
    ld hl, Print.buffer
    ld b,Tilemap.WHITE
    call Print.printString
    ret


;-----------------------------------------------------------------------------------
;  
;-----------------------------------------------------------------------------------
printText:
    call Tilemap.clear

    ; College
    ld e, 10
    call College.getCollegeName
    ld b,Tilemap.DESERT
    call Print.printCentred

    ; Year 
    ld e, 15
    call YearTerm.getYearName
    ld b,Tilemap.YELLOW
    call Print.printCentred

    ; Starting Time
    call RoundVM.printStartingTime
    ld hl, Print.buffer
    ld e, 17
    ld b,Tilemap.TEAL
    call Print.printCentred

    ld e, 22
    ld a, (Puzzles.category)
    call Puzzles.categoryToString
    ld b,Tilemap.RED
    call Print.printCentred


    ; Click to continue
    ld e, 29
    ld hl,startInstruction
    ld b,%00010000
    call Print.printCentred
    ret


startInstruction:
    db "CLICK TO BEGIN YOUR STUDIES",0

spriteData:
    db 14
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,90,TITLE_Y,0,'L'-Tile.ASCII_PATTERN_OFFSET,21,0
    spriteItem 2,110,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,22,0
    spriteItem 3,130,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,23,0
    spriteItem 4,150,TITLE_Y,0,'T'-Tile.ASCII_PATTERN_OFFSET,24,0
    spriteItem 5,170,TITLE_Y,0,'U'-Tile.ASCII_PATTERN_OFFSET,25,0
    spriteItem 6,190,TITLE_Y,0,'R'-Tile.ASCII_PATTERN_OFFSET,26,0
    spriteItem 7,210,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,27,0
    spriteItem 8,110,TITLE_Y2,0,'N'-Tile.ASCII_PATTERN_OFFSET,28,0
    spriteItem 9,130,TITLE_Y2,0,'O'-Tile.ASCII_PATTERN_OFFSET,29,0
    spriteItem 10,150,TITLE_Y2,0,'T'-Tile.ASCII_PATTERN_OFFSET,30,0
    spriteItem 11,170,TITLE_Y2,0,'E'-Tile.ASCII_PATTERN_OFFSET,31,0
    spriteItem 12,190,TITLE_Y2,0,'S'-Tile.ASCII_PATTERN_OFFSET,32,0
    ;Re-roll sprite
    spriteItem 13, REROLL_X, REROLL_Y, 0, Sprites.REROLL | SPRITE_VISIBILITY_MASK, REROLL_BUTTON, MouseDriver.MASK_HOVERABLE | MouseDriver.MASK_CLICKABLE

spriteLen: equ $ - spriteData

    endmodule