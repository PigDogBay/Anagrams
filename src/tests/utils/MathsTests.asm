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

    macro DIV16_TEST dividend, divisor, expected
        ld hl, dividend
        ld e, divisor
        call Maths.div16_8
        ld de, expected
        nop ; ASSERTION BC == DE
    endm

UT_div16_1:
    DIV16_TEST 500,1,500
    DIV16_TEST 500,2,250
    DIV16_TEST 500,3,166
    DIV16_TEST 500,4,125
    DIV16_TEST 40000,4,10000
    DIV16_TEST 40000,8,5000
    DIV16_TEST 1,1,1
    DIV16_TEST 500,0,$ffff
    DIV16_TEST 0,1,0
    DIV16_TEST 65535,255,257

    TC_END


; This test will create 2 x 256 buckets (since HL is 2 x 8 bits)
; The test will record the random values returned in H and L by incrementing the bucket
; So if L is 42, bucket (resultsLow+42) will be incremented
;
; View the results
; -mv TestSuite_Maths.UT_getRandom1.resultsLow 512
;
; most buckets should be C elements
UT_getRandom1:
    ld hl, 0xbeef
    ld (Maths.randomSeed),hl
    ld c,10
.outerloop:
    ld b,255
.innerLoop:    
    call Maths.getRandom
    ex de,hl

    ;Store LSB results in low bucket 0-255 
    ld hl, .resultsLow
    ld a,d
    add hl,a
    ld a,(hl)
    inc a
    ld (hl),a

    ;Store MSB result in high bucket 0-255 
    ld hl, .resultsHigh
    ld a,e
    add hl,a
    ld a,(hl)
    inc a
    ld (hl),a
    djnz .innerLoop
    dec c
    jr nz, .outerloop
    ; LOGPOINT helloword
    ld a,(.resultsLow+42)
    nop ; ASSERTION A > 0
    ld a,(.resultsHigh+99)
    nop ; ASSERTION A > 0

    TC_END
.resultsLow:
    block 256,0
.resultsHigh:
    block 256,0


UT_rnd1:
    ld hl, 0xcafe
    ld (Maths.randomSeed),hl
    ld b,255
    ld d,0
.loop:    
    ld a,10
    call Maths.rnd
    nop ; ASSERTION A<10
    djnz .loop

    TC_END

;Checks rnd 0-49, prints results to the debug console
UT_rnd2:
    ld hl, 0xbeef
    ld (Maths.randomSeed),hl
    ld c,10
.outerloop:
    ld b,255
.innerLoop:    
    ld a,50
    call Maths.rnd

    ;Store the results in the bucket
    ld hl, .bucket
    add hl,a
    ld a,(hl)
    inc a
    ld (hl),a

    djnz .innerLoop
    dec c
    jr nz, .outerloop

    ; Print Bucket
    ld b,50
    ld hl, .bucket
.printLoop:
    ld a,(hl)
    ; LOGPOINT [RND] ${A} ${50-B}
    inc hl
    djnz .printLoop    

    TC_END
.bucket:
    block 256,0


;
; difference tests
;
    macro DIFF_TEST val1, val2, expectedDiff
    ld d, val1
    ld e, val2
    call Maths.difference
    ld d, expectedDiff
    nop ; ASSERTION A == D
    endm

UT_difference1:
    DIFF_TEST 0,0,0
    DIFF_TEST 0,1,1
    DIFF_TEST 1,1,0
    DIFF_TEST 42,142,100
    DIFF_TEST 142,42,100
    DIFF_TEST 0,255,255
    DIFF_TEST 255,0,255
    TC_END


;
; difference16 tests
;
    macro DIFF16_TEST val1, val2, expectedDiff
    ld hl, val1
    ld de, val2
    call Maths.difference16
    ld de, expectedDiff
    nop ; ASSERTION HL == DE
    endm

UT_difference16_1:
    DIFF16_TEST 0,0,0
    DIFF16_TEST 0,1,1
    DIFF16_TEST 1,1,0
    DIFF16_TEST 42,142,100
    DIFF16_TEST 142,42,100
    DIFF16_TEST 0,255,255
    DIFF16_TEST 255,0,255

    DIFF16_TEST 10000,25000,15000
    DIFF16_TEST 25000,10000,15000

    DIFF16_TEST 0,65535,65535
    DIFF16_TEST 65535,0,65535

    TC_END



;
; negate tests
;
    macro NEGATE_TEST val,expected
    ld hl,val
    call Maths.negate
    ld de, expected
    nop ; ASSERTION HL == DE
    endm

UT_negate1:
    NEGATE_TEST 0,0
    NEGATE_TEST 1,65535
    NEGATE_TEST 65535,1
    NEGATE_TEST 1000,65536-1000
    NEGATE_TEST 65536-1000,1000

    TC_END

    
    endmodule

