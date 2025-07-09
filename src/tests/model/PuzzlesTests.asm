    module TestSuite_Puzzles

UT_select1:
    ld h,4
    ld l,2
    call Puzzles.select
    TEST_MEMORY_BYTE Puzzles.level,4
    TEST_MEMORY_BYTE Puzzles.round,2
    TC_END

UT_nextLevel1:
    ld hl, $0402
    call Puzzles.select
    call Puzzles.nextLevel
    nop ; ASSERTION A == 5
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
    ld h,Puzzles.LAST_LEVEL+1
    ld l,01
    call Puzzles.select
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



    endmodule
