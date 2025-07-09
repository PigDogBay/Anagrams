    module Puzzles

FIRST_ROUND:    equ 1
LAST_ROUND:     equ 3
LAST_LEVEL:     equ 10

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
    ld a,(level)
    inc a
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
    push de
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
    pop de
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


round:
    db 1
level:
    db 1

jumbled:
    ds 64
;-----------------------------------------------------------------------------------
; 
; List: list of puzzle structs
; 
;-----------------------------------------------------------------------------------
list:
    puzzleStruct CAT_WORLD, world11
    puzzleStruct CAT_WORLD, world12
    puzzleStruct CAT_WORLD, world13

    puzzleStruct CAT_TV, tv11
    puzzleStruct CAT_TV, tv12
    puzzleStruct CAT_TV, tv13

    puzzleStruct CAT_SCIENCE, science11
    puzzleStruct CAT_SCIENCE, science12
    puzzleStruct CAT_SCIENCE, science13

    puzzleStruct CAT_GAMES, games11
    puzzleStruct CAT_GAMES, games12
    puzzleStruct CAT_GAMES, games13

    puzzleStruct CAT_MUSIC, music11
    puzzleStruct CAT_MUSIC, music12
    puzzleStruct CAT_MUSIC, music13

    puzzleStruct CAT_TECH, tech11
    puzzleStruct CAT_TECH, tech12
    puzzleStruct CAT_TECH, tech13

    puzzleStruct CAT_FILM, film11
    puzzleStruct CAT_FILM, film12
    puzzleStruct CAT_FILM, film13

    puzzleStruct CAT_FILM, film21
    puzzleStruct CAT_FILM, film22
    puzzleStruct CAT_FILM, film23

    puzzleStruct CAT_FILM, film31
    puzzleStruct CAT_FILM, film32
    puzzleStruct CAT_FILM, film33

    puzzleStruct CAT_PEOPLE, people11
    puzzleStruct CAT_PEOPLE, people12
    puzzleStruct CAT_PEOPLE, people13

    puzzleStruct CAT_HISTORY, history11
    puzzleStruct CAT_HISTORY, history12
    puzzleStruct CAT_HISTORY, history13
    
    puzzleStruct CAT_CULTURE, culture11
    puzzleStruct CAT_CULTURE, culture12
    puzzleStruct CAT_CULTURE, culture13
list_end:

;-----------------------------------------------------------------------------------
; 
; Data: Puzzle strings  [ptrLabel: db anagram,clue]
; 
;-----------------------------------------------------------------------------------

culture11: db "THE\nMONA LISA",0,"A little smile from Da Vinci",0
culture12: db "THE BIRTH\nOF VENUS",0,"A planet was born",0
culture13: db "THE\nPERSISTENCE\nOF MEMORY",0,"AKA The Melting Clocks",0

history11: db "BATTLE OF\nHASTINGS",0,"1066 and all that",0
history12: db "BATTLE OF\nAGINCOURT",0,"The longbowmen say up yours",0
history13: db "BATTLE OF\nBOSWORTH\nFIELD",0,"The last big fight over flowers",0

people11: db "ALBERT\nEINSTEIN",0,"1905 was his annus mirablis"
people12: db "ISAAC\nNEWTON",0,"Definitely a Spectrum guy"
people13: db "JOCELYN\nBELL",0,"Astronomer who found Little Green Men?"

film31: db "TIME\nBANDITS",0,"Stinking Kevin",0
film33: db "ZERO\nTHEOREM",0,"No idea",0
film32: db "JABBERWOCKY",0,"Nonsense returns Ykcowrebbaj",0

film21: db "THE IPCRESS\nFILE",0,"Mindbending spy thriller",0
film22: db "THE\nITALIAN\nJOB",0,"Blow the bloody doors off",0
film23: db "THE MAN\nWHO WOULD\nBE KING",0,"He maybe Rex",0

film11: db "CAPRICORN\nONE",0,"Astrological conspiracy",0
film12: db "THE\nPARALLAX\nVIEW",0,"Nice scrolling effect",0
film13: db "ALL THE\nPRESIDENTS\nMEN",0,"Not porn, but has deep throat",0

tech11: db "ATARI VCS",0,"2600",0
tech12: db "ACORN ATOM",0,"< Proton & Electron",0
tech13: db "SEGA\nDREAMCAST",0,"Windows CE Console",0

music11: db "DURAN\nDURAN",0,"And you are again?",0
music12: db "THE ACE\nOF SPADES",0,"The best shovel?",0
music13: db "SMELLS\nLIKE TEEN\nSPIRIT",0,"Whiffy adolescent ghost",0

games11: db "DONKEY\nKONG",0,"Mario's first",0
games12: db "JET SET\nWILLY",0,"A member of the mile high club?",0
games13: db "DOOM II\nHELL ON\nEARTH",0,"ID Unknown!",0

world11: db "TAJ\nMAHAL",0,"Marble Mausoleum",0
world12: db "EIFFEL\nTOWER",0,"A View To A Kill",0
world13: db "GREAT\nSPHINX\nOF GIZA",0,"Bomb Jack",0

tv11: db "BABYLON V",0,"Epic Sci-fi",0
tv12: db "BREAKING\nBAD",0,"Heisberg?",0
tv13: db "GAME OF\nTHRONES",0,"T*ts and Dragons",0

science11: db "BUNSEN\nBURNER",0,"Flamethrower?",0
science12: db "DRAKE\nEQUATION",0,"Where is everyone?",0
science13: db "QUANTUM\nMECHANICS",0,"Planck's Baby",0



    endmodule