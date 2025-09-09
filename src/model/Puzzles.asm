;-----------------------------------------------------------------------------------
; Module Puzzles
;
; Handles the games settings and puzzles data
;
; Struct: puzzleStruct
; 
; Function: select(uint8 year, uint8 term)
; Function: nextTerm()
; Function: nextYear()
; Function: isGameOver() -> Boolean
;
; Function: getPuzzle() -> uint16
; Function: getAnagram() -> uint16
; Function: getClue() -> uint16
; Function: jumbleLetters() -> uint16
;
; Function: getCategory() -> uint8
; Function: categoryToString(uint8 cat) -> uint16
;
; ----Prospectus model functions----
;
; Function: getTerm() -> uint8
; Function: getTermName() -> uint16
;
; Function: getYear() -> uint8
; Function: previousYearSelect() -> uint8
; Function: nextYearSelect() -> uint8
; Function: getYearName() -> uint16
;
; Function: getCollege() -> uint8
; Function: resetCollege() -> uint8
; Function: previousCollege() -> uint8
; Function: nextCollege() -> uint8
; Function: getCollegeName() -> uint16
;
; Function: getDifficulty() -> uint8
; Function: getDifficultyName() -> uint16
; Function: previousDifficulty() -> uint8
; Function: nextDifficulty() -> uint8
;
; Function: getStudyAids() -> uint8
; Function: resetStudyAids()
; Function: decreaseStudyAids() -> uint8
; 
;-----------------------------------------------------------------------------------
    module Puzzles

COLLEGE_COUNT: equ 10

ENUM_DIFFICULTY_EASY:   equ 0
ENUM_DIFFICULTY_NORMAL: equ 1
ENUM_DIFFICULTY_HARD:   equ 2
DIFFICULTY_COUNT:       equ 3

STUDY_AIDS_START_COUNT_EASY:   equ 12
STUDY_AIDS_START_COUNT_NORMAL: equ 9
STUDY_AIDS_START_COUNT_HARD:   equ 6


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
; Function: isGameOver() -> Boolean
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
; Function: getTermName() -> uint16
;
; Getter for current term name
;
; Out: HL = pointer to term's name string 
; 
;-----------------------------------------------------------------------------------
getTermName:
    ld a,(term)
    ld hl, termNameStr2
    cp 2
    jr z, .exit
    ld hl, termNameStr3
    cp 3
    jr z, .exit
    ld hl, termNameStr1
.exit:
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
; Function: previousYearSelect() -> uint8
;
; Sets and returns previous year value, will wrap round to LAST_YEAR
;
; Out: A = previous year value 
; 
;-----------------------------------------------------------------------------------
previousYearSelect:
    ld a,(year)
    dec a
    jr nz, .noWrapAround
    ld a, LAST_YEAR
.noWrapAround:
    ld (year),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextYearSelect() -> uint8
;
; Sets and returns next year value, will wrap round to year 1
;
; Out: A = next year value 
; 
;-----------------------------------------------------------------------------------
nextYearSelect:
    ld a,(year)
    inc a
    cp LAST_YEAR + 1
    jr nz, .noWrapAround
    ;Wrap round to yr 1
    ld a,1
.noWrapAround:
    ld (year),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getYearName() -> uint16
;
; Getter for current year name
;
; Out: HL = current year name
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
getYearName:
    push de
    ld a,(year)
    ; Subtract 1 as year starts at 1
    dec a
    ld hl, yearNameJumpTable
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
; Function: getCollege() -> uint8
;
; Getter for college value
;
; Out: A = 0 ..< COLLEGE_COUNT
; 
;-----------------------------------------------------------------------------------
getCollege:
    ld a,(college)
    ret
    
;-----------------------------------------------------------------------------------
; 
; Function: resetCollege() -> uint8
;
; Sets college value to 0
;
; Out: A = 0 
; 
;-----------------------------------------------------------------------------------
resetCollege:
    xor a
    ld (college),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: previousCollege() -> uint8
;
; Sets and returns previous college value, will wrap round to COLLLEGE_LEN-1
;
; Out: A = previous college value 
; 
;-----------------------------------------------------------------------------------
previousCollege:
    ld a,(college)
    or a
    jr nz, .noWrapAround
    ld a, COLLEGE_COUNT
.noWrapAround:
    dec a
    ld (college),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextCollege() -> uint8
;
; Sets and returns next college value, will wrap round to 0
;
; Out: A = next college value 
; 
;-----------------------------------------------------------------------------------
nextCollege:
    ld a,(college)
    inc a
    cp COLLEGE_COUNT
    jr nz, .noWrapAround
    xor a
.noWrapAround:
    ld (college),a
    ret


;-----------------------------------------------------------------------------------
; 
; Function: getCollegeName() -> uint16
;
; Getter for college name
;
; Out: HL = college name
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
getCollegeName:
    push de
    ld a,(college)
    ld hl, collegeNameJumpTable
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
; Function: getDifficulty() -> uint8
;
; Getter for difficulty enum value
;
; Out: A = ENUM_DIFFICULTY_EASY, _NORMAL or _HARD
; 
;-----------------------------------------------------------------------------------
getDifficulty:
    ld a,(difficulty)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getDifficultyName() -> uint16
;
; Getter for difficulty description string
;
; Out: HL = pointer to difficulty desciption string 
; 
;-----------------------------------------------------------------------------------
getDifficultyName:
    ld a,(difficulty)
    ld hl, normalStr
    cp ENUM_DIFFICULTY_NORMAL
    jr z, .exit
    ld hl, hardStr
    cp ENUM_DIFFICULTY_HARD
    jr z, .exit
    ld hl, easyStr
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: previousDifficulty() -> uint8
;
; Sets and returns previous difficulty settinge, will wrap round to ENUM_DIFFICULTY_HARD
;
; Out: A = previous difficulty setting (ENUM_DIFFICULTY_ )
; 
;-----------------------------------------------------------------------------------
previousDifficulty:
    ld a,(difficulty)
    or a
    jr nz, .noWrapAround
    ld a, DIFFICULTY_COUNT
.noWrapAround:
    dec a
    ld (difficulty),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextDifficulty() -> uint8
;
; Sets and returns next difficulty settings, will wrap round to ENUM_DIFFICULTY_EASY
;
; Out: A = next difficulty setting (ENUM_DIFFICULTY_ )
; 
;-----------------------------------------------------------------------------------
nextDifficulty:
    ld a,(difficulty)
    inc a
    cp DIFFICULTY_COUNT
    jr nz, .noWrapAround
    xor a
.noWrapAround:
    ld (difficulty),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getStudyAids() -> uint8
;
; Getter for number of study aids remaining
;
; Out: A = number of remaining study aids
; 
;-----------------------------------------------------------------------------------
getStudyAids:
    ld a,(studyAids)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: resetStudyAids()
;
; Sets the number of study aids based on difficulty setting
;
; Dirty: A, B
; 
;-----------------------------------------------------------------------------------
resetStudyAids:
    ld a,(difficulty)
    ld b,STUDY_AIDS_START_COUNT_NORMAL
    cp ENUM_DIFFICULTY_NORMAL
    jr z, .exit
    ld b,STUDY_AIDS_START_COUNT_HARD
    cp ENUM_DIFFICULTY_HARD
    jr z, .exit
    ld b,STUDY_AIDS_START_COUNT_EASY
.exit:
    ld a,b
    ld (studyAids),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: decreaseStudyAids() -> uint8
;
; Decreases the remaining study aids by 1, to a minimum of 0
;
; Out: A = number of remaining study aids
; 
;-----------------------------------------------------------------------------------
decreaseStudyAids:
    ld a,(studyAids)
    or a
    jr z, .exit
    dec a
    ld (studyAids),a
.exit:
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

termNameStr1: db "Michaelmas",0
termNameStr2: db "Hilary",0
termNameStr3: db "Trinity",0

yearNameJumpTable:
    dw yearNameStr1
    dw yearNameStr2
    dw yearNameStr3
    dw yearNameStr4
    dw yearNameStr5
    dw yearNameStr6
    dw yearNameStr7
    dw yearNameStr8

yearNameStr1: db "Fresher (Yr 1)",0
yearNameStr2: db "Sophomore (Yr 2)",0
yearNameStr3: db "Finals (Yr 3)",0
yearNameStr4: db "Masters (Yr 4)",0
yearNameStr5: db "DPhil (Yr 5)",0
yearNameStr6: db "DPhil (Yr 6)",0
yearNameStr7: db "DPhil (Yr 7)",0
yearNameStr8: db "Professorship (Yr 8)",0

collegeNameJumpTable:
    dw collegeNameStr1
    dw collegeNameStr2
    dw collegeNameStr3
    dw collegeNameStr4
    dw collegeNameStr5
    dw collegeNameStr6
    dw collegeNameStr7
    dw collegeNameStr8
    dw collegeNameStr9
    dw collegeNameStr10

collegeNameStr1: db "Teddy Hall",0
collegeNameStr2: db "Mor-de-Len College",0
collegeNameStr3: db "Old College",0
collegeNameStr4: db "St Henrys",0
collegeNameStr5: db "Bailey Hall",0
collegeNameStr6: db "Lady Holly Hall",0
collegeNameStr7: db "Hertbridge College",0
collegeNameStr8: db "Radnor College",0
collegeNameStr9: db "Winterville",0
collegeNameStr10: db "St Kayleigh's College",0

; ` is ASCII value for £
easyStr:    db "Student Loan `12,000 (Easy)",0
normalStr:  db "Bursary `9,000 (Normal)",0
hardStr:    db "Scholarship `6,000 (Hard)",0

term:
    db 1

year:
    db 1

college:
    db 0

difficulty:
    db ENUM_DIFFICULTY_NORMAL

studyAids:
    db STUDY_AIDS_START_COUNT_NORMAL

jumbled:
    ds 64




    endmodule
