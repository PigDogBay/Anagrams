    module TestSuite_Time

UT_deductTime1:
    ld hl, 1000
    ld (Time.time),hl
    ld a, 100
    call Time.deduct
    nop ; ASSERTION HL == 900
    TC_END

UT_deductTime2:
    ld hl, 200
    ld (Time.time),hl
    ld a, 230
    call Time.deduct
    nop ; ASSERTION HL == 0
    TC_END

UT_deductTime3:
    ld hl, 42
    ld (Time.time),hl
    ld a, 42
    call Time.deduct
    nop ; ASSERTION HL == 0
    TC_END

UT_deductTime4:
    ld hl, 3000
    ld (Time.time),hl
    ld a, 0
    call Time.deduct
    nop ; ASSERTION HL == 3000

    TC_END

    endmodule
