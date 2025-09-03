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
; Function: select(uint8 year, uint8 term)
;
; Sets the year and term. If term or year is invalid, yr 1, term 1 is set
;
; In: H = Year
;     L = Term 
; 
;-----------------------------------------------------------------------------------
select:
    ;Validation, 0 check
    ld a, h
    or a
    jr z, .failed
    ;Max year
    cp a, LAST_YEAR + 1
    jr nc, .failed
    
    ld a, l
    or a
    jr z, .failed
    ;Greater than last term
    cp a, LAST_TERM + 1
    jr nc, .failed

    ; term = l,year = h
    ld (term),hl
    ret

;Gracefully fail by selecting year 1, term 1
.failed:
    ld hl,$0101
    ld (term),hl
    ret


;-----------------------------------------------------------------------------------
; 
; Function: nextTerm()
;
; Each year has 3 terms, this function increase the current term
;
; Out: A = term (1,2,3) or 0 if no more terms (call nextYear())
; 
;-----------------------------------------------------------------------------------
nextTerm:
    ld a,(term)
    inc a
    ld (term),a
    cp LAST_TERM+1
    jr nc, .noMoreTerms
    ret
.noMoreTerms:
    xor a
    ret
;-----------------------------------------------------------------------------------
; 
; Function: nextYear()
;
; Increase the year, term is set to 1 
;
; Out: A = Year (1,2, ...) or 0 if no more years (Game Completed)
; 
;-----------------------------------------------------------------------------------
nextYear:
    ;set round to 1
    ld a,FIRST_TERM
    ld (term),a

    ld a,(year)
    inc a
    ld (year),a
    cp LAST_YEAR+1
    jr nc, .noMoreYears
    ret
.noMoreYears:
    xor a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: isGameOver()
;
; Checks if more years are left, call this function after nextYear()
;
; Out: Z nz = game over, z = current year is valid to play 
;    
; Dirty: A 
; 
;-----------------------------------------------------------------------------------
isGameOver:
    ld a,(year)
    cp LAST_YEAR+1
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
    ; Multiply year-1 by 3 (3 terms per year)
    ld a,(year)
    dec a
    add hl,a
    add hl,a
    add hl,a

    ; Add term-1
    ld a,(term)
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
; Function: getTerm() -> uint8
;
; Getter for current term
;
; Out: A = current term
; 
;-----------------------------------------------------------------------------------
getTerm:
    ld a,(term)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getYear() -> uint8
;
; Getter for current year
;
; Out: A = current year
; 
;-----------------------------------------------------------------------------------
getYear:
    ld a,(year)
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


term:
    db 1
year:
    db 1

jumbled:
    ds 64

    endmodule