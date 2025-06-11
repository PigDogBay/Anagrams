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

    endmodule

