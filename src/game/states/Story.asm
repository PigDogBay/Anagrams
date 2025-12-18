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

STORY_STATE_START:                      equ 0
STORY_STATE_PARA1:                      equ 1
STORY_STATE_PARA2:                      equ 2
STORY_STATE_PARA3:                      equ 3
STORY_STATE_FROM:                       equ 4
STORY_STATE_INSTRUCTION:                equ 5
STORY_STATE_DONE:                       equ 6

STATE_DELAY:                            equ 25

storyState:
    db 0
stateCounter:
    db STATE_DELAY

stateJumpTable:
    dw storyStart
    dw storyPara1
    dw storyPara2
    dw storyPara3
    dw storyFrom
    dw storyInstruction
    dw storyDone


enter:
    L2_SET_IMAGE IMAGE_STORY
    ld a, STORY_STATE_START
    ld (storyState),a
    
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Sound.playWinMusic
    call Tilemap.clear
    call Sound.playStoryMusic
    ret


update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    jr storyStateUpdate

.mousePressed:
    ld a, College.CHRISTMAS_COLLEGE
    ld (College.college),a

    call GamePhases.start
    ;Skip first round screen, so need to call roundStart here
    call GamePhases.roundStart
    
    STOP_ALL_ANIMATION
    TRANSITION_SCREEN GS_START, IMAGE_MICHAELMAS
    ret


storyStateUpdate:
    ld a, (stateCounter)
    dec a
    jr z, .updateState:
    ld (stateCounter),a
    ret

.updateState:
    ld a, STATE_DELAY
    ld (stateCounter),a
    
    ld a,(storyState)
    ld hl, stateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl


storyStart:
    ld a, STORY_STATE_PARA1     
    ld (storyState),a

    ld d,1 : ld e, TEXT_Y - 1: ld hl,dear
    ld b,Tilemap.DARK_TEAL
    call Print.setCursorPosition : call Print.printString

    ret

storyPara1:
    ld a, STORY_STATE_PARA2     
    ld (storyState),a

    ld b,Tilemap.DARK_GREEN
    ld d,1 : ld e, TEXT_Y + 3 : ld hl,para1Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 4: ld hl,para1Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 5: ld hl,para1Line3
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 6: ld hl,para1Line4
    call Print.setCursorPosition : call Print.printString

    ret

storyPara2:
    ld a, STORY_STATE_PARA3     
    ld (storyState),a

    ld b,Tilemap.DARK_TEAL
    ld d,1 : ld e, TEXT_Y + 8: ld hl,para2Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y +9: ld hl,para2Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y +10: ld hl,para2Line3
    call Print.setCursorPosition : call Print.printString

    ret

storyPara3:
    ld a, STORY_STATE_FROM      
    ld (storyState),a

    ld b,Tilemap.DARK_GREEN
    ld d,1 : ld e, TEXT_Y + 12: ld hl,para3Line1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 13: ld hl,para3Line2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 14: ld hl,para3Line3
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 15: ld hl,para3Line4
    call Print.setCursorPosition : call Print.printString

    ret

storyFrom:
    ld a, STORY_STATE_INSTRUCTION
    ld (storyState),a

    ld b,Tilemap.DARK_TEAL
    ld d,1 : ld e, TEXT_Y + 19: ld hl,from1
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 22: ld hl,from2
    call Print.setCursorPosition : call Print.printString
    ld e, TEXT_Y + 23: ld hl,from3
    call Print.setCursorPosition : call Print.printString

    ret

storyInstruction:
    ld a, STORY_STATE_DONE      
    ld (storyState),a

    ld b,Tilemap.GREEN
    ; Click to exit
    ld e, 29
    ld hl,startInstruction
    call Print.setCursorPosition
    call Print.printCentred

    ret

storyDone:
    ret




dear:
    db "Dear Elf,",0

para1Line1
    db "Congratulations! You have been",0
para1Line2
    db "enrolled into Yule University.",0
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


    endmodule