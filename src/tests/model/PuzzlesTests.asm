     module TestSuite_Puzzles


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

     endmodule
