    module TestSuite_Puzzles

UT_getTermName1:
    ld h,4
    ld l,2
    call Puzzles.select
    call Puzzles.getTermName
    nop ; ASSERTION HL == Puzzles.termNameStr2
    TC_END


UT_select1:
    ld h,4
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.year,4
    TEST_MEMORY_BYTE Puzzles.term,2
    TC_END

;Invalid: 0 term
UT_select2:
    ld h,4
    ld l,0
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.year,1
    TEST_MEMORY_BYTE Puzzles.term,1
    TC_END
;Invalid: term = 4 (max 3)
UT_select3:
    ld h,2
    ld l,4
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.year,1
    TEST_MEMORY_BYTE Puzzles.term,1
    TC_END
;Invalid: 0 year
UT_select4:
    ld h,0
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.year,1
    TEST_MEMORY_BYTE Puzzles.term,1
    TC_END
;Invalid: last year + 1
UT_select5:
    ld h,11
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.year,1
    TEST_MEMORY_BYTE Puzzles.term,1
    TC_END

UT_nextYear1:
    ld hl, $0402
    call Puzzles.select
    call Puzzles.nextYear
    nop ; ASSERTION A == 5
    call Puzzles.getYear
    nop ; ASSERTION A == 5
    call Puzzles.getTerm
    nop ; ASSERTION A == 1
    TC_END

UT_nextYear2:
    ld h,Puzzles.LAST_YEAR
    ld l,02
    call Puzzles.select
    call Puzzles.nextYear
    nop ; ASSERTION A == 0
    TC_END


UT_nextterm1:
    ld hl, $0402
    call Puzzles.select
    call Puzzles.nextTerm
    nop ; ASSERTION A == 3
    call Puzzles.getTerm
    nop ; ASSERTION A == 3
    TC_END

UT_nextterm2:
    ld hl, $0403
    call Puzzles.select
    call Puzzles.nextTerm
    nop ; ASSERTION A == 0
    TC_END

UT_isGameOver1:
    ld hl, $0103
    call Puzzles.select
    call Puzzles.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver2:
    ld h,Puzzles.LAST_YEAR
    ld l,03
    call Puzzles.select
    call Puzzles.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver3:
    ld h,Puzzles.LAST_YEAR
    ld l,01
    call Puzzles.select
    call Puzzles.nextYear
    call Puzzles.isGameOver
    TEST_FLAG_NZ
    TC_END


UT_getPuzzle1:
    ld hl, $0101
    call Puzzles.select
    call Puzzles.getPuzzle
    nop ; ASSERTION HL == Puzzles.list
    TC_END

UT_getPuzzle2:
    ld hl, $0502
    call Puzzles.select
    call Puzzles.getPuzzle
    nop ; ASSERTION HL == Puzzles.list + 4*3*3 + 3
    TC_END



UT_getAnagram1:
    ld hl, $0203
    call Puzzles.select
    call Puzzles.getAnagram
    nop ; ASSERTION HL == Puzzles.tv13
    TC_END


UT_getClue1:
    ld hl, $0203
    call Puzzles.select
    call Puzzles.getClue
    nop ; ASSERTION HL == Puzzles.tv13 + 16
    TC_END

UT_getCategory1:
    ld hl, $0203
    call Puzzles.select
    call Puzzles.getCategory
    nop ; ASSERTION A == Puzzles.CAT_TV
    TC_END

UT_categoryToString1:
    ld hl, $0301
    call Puzzles.select
    call Puzzles.getCategory
    call Puzzles.categoryToString
    TEST_STRING_PTR hl, .data
    TC_END
.data:
    db "Science",0

UT_getYearName1:
    ld hl, $0501
    call Puzzles.select
    call Puzzles.getYearName
    TEST_STRING_PTR hl, .data
    TC_END
.data:
    db "DPhil Yr 1",0

UT_getCollegeName1:
    call Puzzles.resetCollege
    ld (Puzzles.college),a
    call Puzzles.getCollegeName
    TEST_STRING_PTR hl, .data
    TC_END
.data:
    db "Teddy Hall",0


UT_collegeNextPrev1:
    call Puzzles.resetCollege
    call Puzzles.nextCollege
    nop ; ASSERTION A == 1
    call Puzzles.previousCollege
    nop ; ASSERTION A == 0
    TC_END

UT_collegeNextPrevWrap1:
    call Puzzles.resetCollege
    call Puzzles.previousCollege
    call Puzzles.getCollege
    nop ; ASSERTION A == Puzzles.COLLEGE_COUNT - 1
    call Puzzles.nextCollege
    nop ; ASSERTION A == 0
    TC_END

UT_yearSelect1:
    ld hl,$0401
    call Puzzles.select
    call Puzzles.previousYearSelect
    nop ; ASSERTION A == 3
    call Puzzles.nextYearSelect
    nop ; ASSERTION A == 4
    TC_END

UT_yearSelectWrap1:
    ld hl,$0101
    call Puzzles.select
    call Puzzles.previousYearSelect
    nop ; ASSERTION A == Puzzles.LAST_YEAR
    call Puzzles.nextYearSelect
    nop ; ASSERTION A == 1
    TC_END
    TC_END

UT_jumbleLetters1:
    ld hl, $0203
    call Puzzles.select
    call Puzzles.jumbleLetters
    nop ; ASSERTION HL == Puzzles.jumbled
    call String.len
    nop ; ASSERTION A == 15
    ld de,hl
    call Puzzles.getAnagram
    call String.equals
    TEST_FLAG_NZ
    TC_END

; Function: getDifficulty() -> uint8
; Function: getDifficultyName() -> uint16
; Function: previousDifficulty() -> uint8
; Function: nextDifficulty() -> uint8
UT_difficulty1:
    ld a, Puzzles.ENUM_DIFFICULTY_NORMAL
    ld (Puzzles.difficulty), a
    call Puzzles.getDifficultyName
    TEST_STRING_PTR hl, Puzzles.normalStr

    call Puzzles.previousDifficulty
    call Puzzles.getDifficultyName
    TEST_STRING_PTR hl, Puzzles.easyStr

    TC_END

UT_difficultyWrap1:
    ld a, Puzzles.ENUM_DIFFICULTY_EASY
    ld (Puzzles.difficulty), a
    call Puzzles.previousDifficulty
    call Puzzles.getDifficulty
    nop ; ASSERTION A == Puzzles.ENUM_DIFFICULTY_HARD
    TC_END

UT_difficultyWrap2:
    ld a, Puzzles.ENUM_DIFFICULTY_HARD
    ld (Puzzles.difficulty), a
    call Puzzles.nextDifficulty
    call Puzzles.getDifficulty
    nop ; ASSERTION A == Puzzles.ENUM_DIFFICULTY_EASY
    TC_END

; Function: getStudyAids() -> uint8
; Function: resetStudyAids()
; Function: decreaseStudyAids() -> uint8

UT_resetStudyAids1
    ld a, Puzzles.ENUM_DIFFICULTY_EASY
    ld (Puzzles.difficulty), a
    call Puzzles.resetStudyAids
    call Puzzles.getStudyAids
    nop ; ASSERTION A == Puzzles.STUDY_AIDS_START_COUNT_EASY
    TC_END
UT_resetStudyAids2
    ld a, Puzzles.ENUM_DIFFICULTY_NORMAL
    ld (Puzzles.difficulty), a
    call Puzzles.resetStudyAids
    call Puzzles.getStudyAids
    nop ; ASSERTION A == Puzzles.STUDY_AIDS_START_COUNT_NORMAL
    TC_END
UT_resetStudyAids3
    ld a, Puzzles.ENUM_DIFFICULTY_HARD
    ld (Puzzles.difficulty), a
    call Puzzles.resetStudyAids
    call Puzzles.getStudyAids
    nop ; ASSERTION A == Puzzles.STUDY_AIDS_START_COUNT_HARD
    TC_END

UT_decreaseStudyAids1
    ld a, Puzzles.ENUM_DIFFICULTY_NORMAL
    ld (Puzzles.difficulty), a
    call Puzzles.resetStudyAids
    call Puzzles.decreaseStudyAids
    call Puzzles.getStudyAids
    nop ; ASSERTION A == Puzzles.STUDY_AIDS_START_COUNT_NORMAL - 1
    TC_END

UT_decreaseStudyAids2
    ld a, 0
    ld (Puzzles.studyAids), a
    call Puzzles.decreaseStudyAids
    call Puzzles.getStudyAids
    nop ; ASSERTION A == 0
    TC_END


UT_behaviour1:
    ld hl,$0101
    ld b,0
    ;Check C, not corrupted
    ld c,42
    ;Check DE, not corrupted
    ld de,$BABE
    call Puzzles.select
.nextPuzzle:
    inc b
    call Puzzles.isGameOver
    TEST_FLAG_Z

    call Puzzles.jumbleLetters
    call Puzzles.getCategory
    call Puzzles.getAnagram
    call Puzzles.getClue

    call Puzzles.nextTerm
    or a
    jr nz, .nextPuzzle
    
    call Puzzles.nextYear
    or a
    jr nz, .nextPuzzle
    
    call Puzzles.isGameOver
    TEST_FLAG_NZ

    nop ; ASSERTION B == 30    
    nop ; ASSERTION DE == $BABE
    nop ; ASSERTION C == 42
    TC_END

    endmodule
