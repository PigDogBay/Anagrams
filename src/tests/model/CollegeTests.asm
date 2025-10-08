    module TestSuite_College


UT_getCollegeName1:
    call College.resetCollege
    ld (College.college),a
    call College.getCollegeName
    TEST_STRING_PTR hl, .data
    TC_END
.data:
    db "TEDDY HALL",0


UT_collegeNextPrev1:
    call College.resetCollege
    call College.nextCollege
    nop ; ASSERTION A == 1
    call College.previousCollege
    nop ; ASSERTION A == 0
    TC_END

UT_collegeNextPrevWrap1:
    call College.resetCollege
    call College.previousCollege
    call College.getCollege
    nop ; ASSERTION A == College.COLLEGE_COUNT - 1
    call College.nextCollege
    nop ; ASSERTION A == 0
    TC_END

UT_getCollegeStruct1:
    call College.resetCollege
    call College.nextCollege
    call College.nextCollege
    call College.getCollegeStruct
    nop ; ASSERTION  HL == College.gameSettings + collegeStruct * 2
    TC_END


    endmodule
