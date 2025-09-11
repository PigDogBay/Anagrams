    module TestSuite_YearTerm

UT_getYearName1:
    ld hl, $0501
    call YearTerm.select
    call YearTerm.getYearName
    TEST_STRING_PTR hl, YearTerm.yearNameStr5
    TC_END

UT_getTermName1:
    ld h,4
    ld l,2
    call YearTerm.select
    call YearTerm.getTermName
    nop ; ASSERTION HL == YearTerm.termNameStr2
    TC_END


UT_select1:
    ld h,4
    ld l,2
    call YearTerm.select
    TEST_MEMORY_BYTE YearTerm.year,4
    TEST_MEMORY_BYTE YearTerm.term,2
    TC_END

;Invalid: 0 term
UT_select2:
    ld h,4
    ld l,0
    call YearTerm.select
    TEST_MEMORY_BYTE YearTerm.year,1
    TEST_MEMORY_BYTE YearTerm.term,1
    TC_END
;Invalid: term = 4 (max 3)
UT_select3:
    ld h,2
    ld l,4
    call YearTerm.select
    TEST_MEMORY_BYTE YearTerm.year,1
    TEST_MEMORY_BYTE YearTerm.term,1
    TC_END
;Invalid: 0 year
UT_select4:
    ld h,0
    ld l,2
    call YearTerm.select
    TEST_MEMORY_BYTE YearTerm.year,1
    TEST_MEMORY_BYTE YearTerm.term,1
    TC_END
;Invalid: last year + 1
UT_select5:
    ld h,11
    ld l,2
    call YearTerm.select
    TEST_MEMORY_BYTE YearTerm.year,1
    TEST_MEMORY_BYTE YearTerm.term,1
    TC_END

UT_nextYear1:
    ld hl, $0402
    call YearTerm.select
    call YearTerm.nextYear
    nop ; ASSERTION A == 5
    call YearTerm.getYear
    nop ; ASSERTION A == 5
    call YearTerm.getTerm
    nop ; ASSERTION A == 1
    TC_END

UT_nextYear2:
    ld h,YearTerm.LAST_YEAR
    ld l,02
    call YearTerm.select
    call YearTerm.nextYear
    nop ; ASSERTION A == 0
    TC_END


UT_nextterm1:
    ld hl, $0402
    call YearTerm.select
    call YearTerm.nextTerm
    nop ; ASSERTION A == 3
    call YearTerm.getTerm
    nop ; ASSERTION A == 3
    TC_END

UT_nextterm2:
    ld hl, $0403
    call YearTerm.select
    call YearTerm.nextTerm
    nop ; ASSERTION A == 0
    TC_END

UT_isGameOver1:
    ld hl, $0103
    call YearTerm.select
    call YearTerm.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver2:
    ld h,YearTerm.LAST_YEAR
    ld l,03
    call YearTerm.select
    call YearTerm.isGameOver
    TEST_FLAG_Z
    TC_END
UT_isGameOver3:
    ld h,YearTerm.LAST_YEAR
    ld l,01
    call YearTerm.select
    call YearTerm.nextYear
    call YearTerm.isGameOver
    TEST_FLAG_NZ
    TC_END

UT_yearSelect1:
    ld hl,$0401
    call YearTerm.select
    call YearTerm.previousYearSelect
    nop ; ASSERTION A == 3
    call YearTerm.nextYearSelect
    nop ; ASSERTION A == 4
    TC_END

UT_yearSelectWrap1:
    ld hl,$0101
    call YearTerm.select
    call YearTerm.previousYearSelect
    nop ; ASSERTION A == YearTerm.LAST_YEAR
    call YearTerm.nextYearSelect
    nop ; ASSERTION A == 1
    TC_END



    endmodule
