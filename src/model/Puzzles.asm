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
    ; Multiply year-1 by 3 (3 terms per year)
    ld a,(YearTerm.year)
    dec a
    add hl,a
    add hl,a
    add hl,a

    ; Add term-1
    ld a,(YearTerm.term)
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


;-----------------------------------------------------------------------------------
; 
; Variables to hold puzzle data 
; 
;-----------------------------------------------------------------------------------
jumbled:    ds 40
clue:       ds 40
puzzle1:    ds 40   
puzzle2:    ds 40   
puzzle3:    ds 40   

    endmodule
