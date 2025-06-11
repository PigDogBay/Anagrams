    module TestSuite_Maths

    macro DIV_MOD_TEST dividend, divisor, expectedRemainder, expectedQuotient
    ld a, dividend
    ld b, divisor
    call Maths.divMod
    ld d, expectedRemainder
    nop ; ASSERTION A == D
    ld d, expectedQuotient
    nop ; ASSERTION C == D
    endm

UT_divMod1:
    DIV_MOD_TEST 7,7,0,1
    DIV_MOD_TEST 14,7,0,2
    DIV_MOD_TEST 3,2,1,1
    DIV_MOD_TEST 2,3,2,0
    DIV_MOD_TEST 0,1,0,0
    DIV_MOD_TEST 2,0,255,255
    DIV_MOD_TEST 255,1,0,255
    DIV_MOD_TEST 253,6,1,42
    DIV_MOD_TEST 251,6,5,41


    TC_END

    endmodule