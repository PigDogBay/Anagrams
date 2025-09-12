    module TestSuite_Puzzles


UT_getPuzzle1:
    ld hl, $0101
    call YearTerm.select
    call Puzzles.getPuzzle
    nop ; ASSERTION HL == Puzzles.list
    TC_END

UT_getPuzzle2:
    ld hl, $0502
    call YearTerm.select
    call Puzzles.getPuzzle
    nop ; ASSERTION HL == Puzzles.list + 4*3*3 + 3
    TC_END



UT_getAnagram1:
    ld hl, $0203
    call YearTerm.select
    call Puzzles.getAnagram
    nop ; ASSERTION HL == Puzzles.tv13
    TC_END


UT_getClue1:
    ld hl, $0203
    call YearTerm.select
    call Puzzles.getClue
    nop ; ASSERTION HL == Puzzles.tv13 + 16
    TC_END

UT_getCategory1:
    ld hl, $0203
    call YearTerm.select
    call Puzzles.getCategory
    nop ; ASSERTION A == Puzzles.CAT_TV
    TC_END

UT_categoryToString1:
    ld hl, $0301
    call YearTerm.select
    call Puzzles.getCategory
    call Puzzles.categoryToString
    TEST_STRING_PTR hl, .data
    TC_END
.data:
    db "Science",0


UT_jumbleLetters1:
    ld hl, $0203
    call YearTerm.select
    call Puzzles.jumbleLetters
    nop ; ASSERTION HL == Puzzles.jumbled
    call String.len
    nop ; ASSERTION A == 15
    ld de,hl
    call Puzzles.getAnagram
    call String.equals
    TEST_FLAG_NZ
    TC_END


; -mv Puzzles.clue 320
UT_copyPuzzleStrings1:
    ld a,0
    ld b,BANK_CAT_MUSIC
    call Puzzles.copyPuzzleStrings
    TEST_STRING_PTR Puzzles.clue, .e1
    TEST_STRING_PTR Puzzles.puzzle1, .e2
    TEST_STRING_PTR Puzzles.puzzle2, .e3
    TEST_STRING_PTR Puzzles.puzzle3, .e4

    nop
    TC_END
.e1: db "80's POP BANDS",0
.e2: db "DURAN\nDURAN",0
.e3: db "CULTURE\nCLUB",0
.e4: db "A FLOCK OF\nSEAGULLS",0

; -mv Puzzles.clue 320
UT_copyPuzzleStrings2:
    ld a,42
    ld b,BANK_CAT_MUSIC
    call Puzzles.copyPuzzleStrings
    TEST_STRING_PTR Puzzles.clue, .e1
    TEST_STRING_PTR Puzzles.puzzle1, .e2
    TEST_STRING_PTR Puzzles.puzzle2, .e3
    TEST_STRING_PTR Puzzles.puzzle3, .e4

    nop
    TC_END
.e1  db "THE MACC LADS",0
.e2  db "SWEATY\nBETTY",0
.e3  db "FELLATIO\nNELSON",0
.e4  db "GODS GIFT\nTO WOMEN",0

UT_behaviour1:
    ld hl,$0101
    ld b,0
    ;Check C, not corrupted
    ld c,42
    ;Check DE, not corrupted
    ld de,$BABE
    call YearTerm.select
.nextPuzzle:
    inc b
    call YearTerm.isGameOver
    TEST_FLAG_Z

    call Puzzles.jumbleLetters
    call Puzzles.getCategory
    call Puzzles.getAnagram
    call Puzzles.getClue

    call YearTerm.nextTerm
    or a
    jr nz, .nextPuzzle
    
    call YearTerm.nextYear
    or a
    jr nz, .nextPuzzle
    
    call YearTerm.isGameOver
    TEST_FLAG_NZ

    nop ; ASSERTION B == 24    
    nop ; ASSERTION DE == $BABE
    nop ; ASSERTION C == 42
    TC_END

    endmodule
