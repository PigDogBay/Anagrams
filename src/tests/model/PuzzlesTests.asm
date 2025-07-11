    module TestSuite_Puzzles

UT_select1:
    ld h,4
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,4
    TEST_MEMORY_BYTE Puzzles.round,2
    TC_END

;Invalid: 0 round
UT_select2:
    ld h,4
    ld l,0
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,1
    TEST_MEMORY_BYTE Puzzles.round,1
    TC_END
;Invalid: round = 4 (max 3)
UT_select3:
    ld h,2
    ld l,4
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,1
    TEST_MEMORY_BYTE Puzzles.round,1
    TC_END
;Invalid: 0 level
UT_select4:
    ld h,0
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,1
    TEST_MEMORY_BYTE Puzzles.round,1
    TC_END
;Invalid: last level + 1
UT_select5:
    ld h,11
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,1
    TEST_MEMORY_BYTE Puzzles.round,1
    TC_END

UT_nextLevel1:
    ld hl, $0402
    call Puzzles.select
    call Puzzles.nextLevel
    nop ; ASSERTION A == 5
    call Puzzles.getLevel
    nop ; ASSERTION A == 5
    call Puzzles.getRound
    nop ; ASSERTION A == 1
    TC_END

UT_nextLevel2:
    ld h,Puzzles.LAST_LEVEL
    ld l,02
    call Puzzles.select
    call Puzzles.nextLevel
    nop ; ASSERTION A == 0
    TC_END


UT_nextRound1:
    ld hl, $0402
    call Puzzles.select
    call Puzzles.nextRound
    nop ; ASSERTION A == 3
    call Puzzles.getRound
    nop ; ASSERTION A == 3
    TC_END

UT_nextRound2:
    ld hl, $0403
    call Puzzles.select
    call Puzzles.nextRound
    nop ; ASSERTION A == 0
    TC_END

UT_isGameOver1:
    ld hl, $0103
    call Puzzles.select
    call Puzzles.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver2:
    ld h,Puzzles.LAST_LEVEL
    ld l,03
    call Puzzles.select
    call Puzzles.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver3:
    ld h,Puzzles.LAST_LEVEL
    ld l,01
    call Puzzles.select
    call Puzzles.nextLevel
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

    call Puzzles.nextRound
    or a
    jr nz, .nextPuzzle
    
    call Puzzles.nextLevel
    or a
    jr nz, .nextPuzzle
    
    call Puzzles.isGameOver
    TEST_FLAG_NZ

    nop ; ASSERTION B == 30    
    nop ; ASSERTION DE == $BABE
    nop ; ASSERTION C == 42
    TC_END

    endmodule
