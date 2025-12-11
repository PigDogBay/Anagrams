;-----------------------------------------------------------------------------------
; 
; State: Story
; 
; Welcome message before the start of a game
; 
;-----------------------------------------------------------------------------------

    module GameState_Story

@GS_STORY: 
    stateStruct enter,update

TITLE_Y equ 10
TEXT_Y equ 2

enter:
    L2_SET_IMAGE IMAGE_STORY
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer


    ;Animated Sprite Tile
    ;Add slots and amke SYLLABUS tiles appear

    ; ld bc, spriteLen
    ; ld de, SpriteList.count
    ; ld hl, spriteData
    ; ldir
    ; call Visibility.removeAll
    ; ;B - gameId, C - delay
    ; ld b, 1 : ld c, 14 : call Visibility.add
    ; ld b, 2 : ld c, 18: call Visibility.add
    ; ld b, 3 : ld c, 22 : call Visibility.add
    ; ld b, 4 : ld c, 26 : call Visibility.add
    ; ld b, 5 : ld c, 30 : call Visibility.add
    ; ld b, 6 : ld c, 34 : call Visibility.add
    ; ld b, 7 : ld c, 38 : call Visibility.add
    ; call Visibility.start
    call Sound.playWinMusic
    jp printText


update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    call GamePhases.start
    ;Skip first round screen, so need to call roundStart here
    call GamePhases.roundStart
    
    STOP_ALL_ANIMATION
    TRANSITION_SCREEN GS_START, IMAGE_MICHAELMAS
    ret

printText:
    call Tilemap.clear

    ld e, TEXT_Y - 1: ld hl,dear
    ld b,Tilemap.DARK_TEAL
    ld d, 1 : call Print.setCursorPosition : call Print.printString

    ld b,Tilemap.DARK_GREEN
    ld e, TEXT_Y + 3: ld hl,para1Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 4: ld hl,para1Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 5: ld hl,para1Line3
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 6: ld hl,para1Line4
    call Print.setCursorPosition : call Print.printString


    ld b,Tilemap.DARK_TEAL
    ld e, TEXT_Y + 8: ld hl,para2Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y +9: ld hl,para2Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y +10: ld hl,para2Line3
    call Print.setCursorPosition : call Print.printString

    ld b,Tilemap.DARK_GREEN
    ld e, TEXT_Y + 12: ld hl,para3Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 13: ld hl,para3Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 14: ld hl,para3Line3
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 15: ld hl,para3Line4
    call Print.setCursorPosition : call Print.printString

    ld b,Tilemap.DARK_TEAL

    ld e, TEXT_Y + 19: ld hl,from1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 22: ld hl,from2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 23: ld hl,from3
    call Print.setCursorPosition : call Print.printString

    ld b,Tilemap.GREEN

    ; Click to exit
    ld e, 29
    ld hl,startInstruction
    call Print.setCursorPosition
    call Print.printCentred
    ret

dear:
    db "Dear Elf,",0

para1Line1
    db "Congratulations! You have been",0
para1Line2
    db "enrolled into the University of Yule.",0
para1Line3
    db "We hope your  8  years here is an",0
para1Line4
    db "enlightening festive experience.",0

para2Line1
    db "Each year will have  3  terms that",0
para2Line2
    db "will cover one particular aspect",0
para2Line3
    db "about Christmas.",0

para3Line1
    db "You will be provided with 4 study",0
para3Line2
    db "aids, we recommend that you make good",0
para3Line3
    db "use of them to guide you through",0
para3Line4
    db "your studies.",0

from1:
    db "Yours Sincerely,",0
from2:
    db "Professor Kris Kringle",0
from3:
    db "Department of Christmasology",0




startInstruction:
    db "CLICK TO BEGIN YOUR STUDIES",0


spriteData:
    db 8
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0 | SPRITE_VISIBILITY_MASK,0,0

    ;Tile sprites
    spriteItem 1,90,TITLE_Y,0,'W'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,110,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,130,TITLE_Y,0,'L'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,150,TITLE_Y,0,'C'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,170,TITLE_Y,0,'O'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,190,TITLE_Y,0,'M'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,210,TITLE_Y,0,'E'-Tile.ASCII_PATTERN_OFFSET,7,0

spriteLen: equ $ - spriteData

    endmodule