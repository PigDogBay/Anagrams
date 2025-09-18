;-----------------------------------------------------------------------------------
; Module Puzzles
;
; Handles the puzzles data
;
; Struct: puzzleStruct
;
; Function: getPuzzle() -> uint16
; Function: getAnagram() -> uint16
; Function: getClue() -> uint16
; Function: jumbleLetters() -> uint16
;
; Function: getCategory() -> uint8
; Function: categoryToString(uint8 cat) -> uint16
; 
;-----------------------------------------------------------------------------------
    module Puzzles

PUZZLE_COUNT        equ 50
CAT_COUNT           equ 7

;-----------------------------------------------------------------------------------
; 
; Function: newCategory() -> uint8
;
; For the first year, category is always Freshers
; For year 2+, category is:
;  - Random
;  - Never freshers
;  - Different from the previous category
;
; Out: A = Category
;
;
;-----------------------------------------------------------------------------------
;@INTERRUPT
newCategory:
    push bc
    ;First year is always freshers
    ld a,(YearTerm.year)
    cp 1
    ld a, CAT_FRESHERS
    jr z, .exit

    ld a, (category)
    ld b,a

.differentCatRequired:
    ;randomly select category
    ;CAT_FRESHERS is 0, so need random from 1 to count-1 
    ld a, CAT_COUNT - 1
    call Maths.rnd
    inc a
    ;Check cataegory is different from the previous category
    cp b
    jr z, .differentCatRequired
.exit:
    ld (category),a
    pop bc
    ret




;-----------------------------------------------------------------------------------
; 
; Function: copyRandomPuzzle(uint8 cat) -> uint16.  @INTERRUPT
;
; Copies a random puzzle into this modules puzzle variables
;
; In A Catgeory
;
; Dirty: A, B
;
;-----------------------------------------------------------------------------------
;@INTERRUPT
copyRandomPuzzle:
    ;Map category to puzzle bank
    ld b,BANK_PUZZLES_START
    add b
    ld b,a

    ;copy a random puzzle
    ld a,PUZZLE_COUNT
    call Maths.rnd
    call Puzzles.copyPuzzleStrings
    ret


;-----------------------------------------------------------------------------------
; 
; Function: getPuzzle() -> uint16
;
; Getter for pointer to the current terms puzzle string
;
; Out: HL = pointer to current terms puzzle string
;
; Dirty: HL, A
;
;-----------------------------------------------------------------------------------
getPuzzle:
    ld a,(YearTerm.term)
    ld hl, puzzle2
    cp 2
    jr z, .exit
    ld hl, puzzle3
    cp 3
    jr z, .exit
    ld hl, puzzle1
.exit:
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
    call getPuzzle
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
; Function: copyPuzzleStrings(uint8 bank, uint8 index) @INTERRUPT
;
; Copies the puzzle data into this modules variables
; ----DISABLE INTERRUPTS BEFORE CALLING THIS FUNCTION----
;
; In: A = Puzzle Index 0-49
;     B = Bank of the puzzle data, in Slot 0
;     
; 
;-----------------------------------------------------------------------------------
;@INTERRUPT
copyPuzzleStrings:
    push af,bc,de,hl

    ;look up puzzle address from the table
    ld hl,0
    ;Add puzzle index twice, as pointer is 16bits
    add hl,a
    add hl,a
    ld a,b
    ; swap out ROM with bank
    nextreg MMU_0,a 
    ld de,(hl)
    ex de, hl

    ld de, clue : call String.copy
    ld de, puzzle1 : call String.copy
    ld de, puzzle2 : call String.copy
    ld de, puzzle3 : call String.copy

    ; Restore ROM
    nextreg MMU_0, $FF

    pop hl,de,bc,af
    ret




;-----------------------------------------------------------------------------------
; 
; Enum: Category
; 
;-----------------------------------------------------------------------------------
@CAT_FRESHERS:       equ 0
@CAT_MUSIC:          equ 1
@CAT_FILM:           equ 2
@CAT_WORLD:          equ 3
@CAT_SCIENCE:        equ 4
@CAT_GAMES:          equ 5
@CAT_HISTORY:        equ 6
@CAT_PEOPLE:         equ 7
@CAT_CULTURE:        equ 8
@CAT_FOOD:           equ 9


catStringJumpTable:
    dw catFreshers
    dw catMusicStr
    dw catFilmTvStr
    dw catWorldStr
    dw catScienceStr
    dw catGamesStr
    dw catPeopleStr
    dw catCultureStr
    dw catHistoryStr
    dw catFoodStr

catFreshers: db "FRESHERS",0
catMusicStr: db "MUSIC",0
catFilmTvStr: db "FILM AND TV",0
catGamesStr: db "GAMES AND TECh",0
catPeopleStr: db "PEOPLE",0
catCultureStr: db "CULTURE",0
catWorldStr: db "WORLD",0
catHistoryStr: db "HISTORY",0
catScienceStr: db "SCIENCE",0
catFoodStr: db "FOOD",0


;-----------------------------------------------------------------------------------
; 
; Variables to hold puzzle data 
; 
;-----------------------------------------------------------------------------------
;-mv Puzzles.category 256
category:   db 0
jumbled:    ds 40
clue:       ds 40
puzzle1:    ds 40   
puzzle2:    ds 40   
puzzle3:    ds 40   

    endmodule
