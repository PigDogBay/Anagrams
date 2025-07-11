    module Puzzles

;-----------------------------------------------------------------------------------
; 
; Struct: puzzleStruct
; 
; .category = CAT_ enum
; .word = pointer to puzzle
; 
;-----------------------------------------------------------------------------------
    struct @puzzleStruct
category    byte
puzzle      word
    ends


;-----------------------------------------------------------------------------------
; 
; Function: select(uint8 level, uint8 round)
;
; Sets the round and level. If round or level is invalid, lvl 1, rnd 1 is set
;
; In: H = level
;     L = round 
; 
;-----------------------------------------------------------------------------------
select:
    ;Validation, 0 check
    ld a, h
    or a
    jr z, .failed
    ;Max level
    cp a, LAST_LEVEL + 1
    jr nc, .failed
    
    ld a, l
    or a
    jr z, .failed
    ;Greater than last round
    ;Max level
    cp a, LAST_ROUND + 1
    jr nc, .failed

    ; round = l,level = h
    ld (round),hl
    ret

;Gracefully fail by selecting level 1, round 1
.failed:
    ld hl,$0101
    ld (round),hl
    ret


;-----------------------------------------------------------------------------------
; 
; Function: nextRound()
;
; Each level has 3 rounds, this function increase the current round 
;
; Out: A = round (1,2,3) or 0 if no more rounds (call nextLevel())
; 
;-----------------------------------------------------------------------------------
nextRound:
    ld a,(round)
    inc a
    ld (round),a
    cp LAST_ROUND+1
    jr nc, .noMoreRounds
    ret
.noMoreRounds:
    xor a
    ret
;-----------------------------------------------------------------------------------
; 
; Function: nextLevel()
;
; Increase the level, round is set to 1 
;
; Out: A = Level (1,2, ...) or 0 if no more levels (Game Completed)
; 
;-----------------------------------------------------------------------------------
nextLevel:
    ;set round to 1
    ld a,FIRST_ROUND
    ld (round),a

    ld a,(level)
    inc a
    ld (level),a
    cp LAST_LEVEL+1
    jr nc, .noMoreLevels
    ret
.noMoreLevels:
    xor a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: isGameOver()
;
; Checks if more levels are left, call this function after nextLevel()
;
; Out: Z nz = game over, z = current level is valid to play 
;    
; Dirty: A 
; 
;-----------------------------------------------------------------------------------
isGameOver:
    ld a,(level)
    cp LAST_LEVEL+1
    jr c, .false 
    ; Reset zero flag to indicate TRUE
    ld a,1
    or a
    ret
.false:
    ;Set zero flag. to indicate FALSE
    xor a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getPuzzle() -> uint16
;
; Getter for pointer to current puzzle struct
;
; Out: HL = pointer to current selected puzzleStruct
;
; Dirty: DE, A
;
;-----------------------------------------------------------------------------------
getPuzzle:
    ld hl,0
    ; Multiply level-1 by 3 (3 rounds per level)
    ld a,(level)
    dec a
    add hl,a
    add hl,a
    add hl,a

    ; Add round-1
    ld a,(round)
    dec a
    add hl,a

    ;Multiply by 3 (puzzleStruct.size = 3 bytes)
    ld de,hl
    add hl,de
    add hl,de
    add hl,list
    ret


;-----------------------------------------------------------------------------------
; 
; Function: getAnagram() -> uint16
;
; Getter for pointer to the anagram string
;
; Out: HL = pointer to current anagram string
;
; Dirty: A
; 
;-----------------------------------------------------------------------------------
getAnagram:
    push de
    call getPuzzle
    ;HL now points to puzzle struct
    ;Skip category (1 byte)
    inc hl
    ;hl now points to a pointer to the anagram string
    ;Load pointer into HL
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex hl,de
    pop de
    ret


;-----------------------------------------------------------------------------------
; 
; Function: getClue() -> uint16
;
; Getter for the pointer to the currenly selected puzzles clue string
;
; Out: HL = pointer to string
; 
;-----------------------------------------------------------------------------------
getClue:
    push de
    call getAnagram
.nextChar:
    ; find the null terminator \0
    ld a,(hl)
    inc hl
    or a
    jr nz, .nextChar 
    ; HL should now point to the Clue string
    pop de
    ret



;-----------------------------------------------------------------------------------
; 
; Function: jumbleLetters() -> uint16
;
; Copies the current anagram and then jumbles up the letters
;
; Out: HL = pointer to jumbled letters string
; 
;-----------------------------------------------------------------------------------
jumbleLetters:
    push de,bc
    call getAnagram
    ; copy string
    ld de,jumbled
.copy:
    ldi
    ld a,(hl)
    or a
    jr nz, .copy

    ;copy the null terminator
    ldi
    ld hl, jumbled
    call String.shuffle
    pop bc,de
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getCategory() -> uint8
;
; Getter for category of the currently selected puzzle
;
; Out: A = category
; 
;-----------------------------------------------------------------------------------
getCategory:
    push de, hl
    call getPuzzle
    ;HL now points to puzzle struct, first byte is the category
    ld a,(hl)
    pop hl, de
    ret


;-----------------------------------------------------------------------------------
; 
; Function: categoryToString(uint8 cat) -> uint16
;
; Ges the matching string for the the category enum value
;
; In: A = category
; Out: HL = pointer to category display string
; 
;-----------------------------------------------------------------------------------
categoryToString:
    push de
    ld hl, catStringJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    pop de
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getRound() -> uint8
;
; Getter for current round
;
; Out: A = current round
; 
;-----------------------------------------------------------------------------------
getRound:
    ld a,(round)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getLevel() -> uint8
;
; Getter for current level
;
; Out: A = current level
; 
;-----------------------------------------------------------------------------------
getLevel:
    ld a,(level)
    ret

;-----------------------------------------------------------------------------------
; 
; Enum: Category
; 
;-----------------------------------------------------------------------------------
CAT_MUSIC:          equ 1
CAT_FILM:           equ 2
CAT_TV:             equ 3
CAT_GAMES:          equ 4
CAT_TECH:           equ 5
CAT_PEOPLE:         equ 6
CAT_CULTURE:        equ 7
CAT_WORLD:          equ 8
CAT_HISTORY:        equ 9
CAT_SCIENCE:        equ 10
CAT_FOOD:           equ 11


catStringJumpTable:
    dw catBadStr
    dw catMusicStr
    dw catFilmStr
    dw catTvStr
    dw catGamesStr
    dw catTechStr
    dw catPeopleStr
    dw catCultureStr
    dw catWorldStr
    dw catHistoryStr
    dw catScienceStr
    dw catFoodStr

catBadStr: db "Illegal value",0
catMusicStr: db "Music",0
catFilmStr: db "Film",0
catTvStr: db "TV",0
catGamesStr: db "Games",0
catTechStr: db "Tech",0
catPeopleStr: db "People",0
catCultureStr: db "Culture",0
catWorldStr: db "World",0
catHistoryStr: db "History",0
catScienceStr: db "Science",0
catFoodStr: db "Food",0


round:
    db 1
level:
    db 1

jumbled:
    ds 64

    endmodule