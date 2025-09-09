    module TestSuite_ScoresConvertTests

; Dezog deug console, memory viewer
; -mv TestSuite_ScoresConvertTests.buffer 16
buffer:
    block 6

UT_ConvertToDecimal1:
    ld hl,0
    ld a,1
    ld de, buffer
    call ScoresConvert.ConvertToDecimal
    TEST_STRING_PTR buffer, .expectedString
    nop ; ASSERTION A == 1
    TC_END
.expectedString:
    db "0",0

;Leading zeros
UT_ConvertToDecimal2:
    ld hl,0
    ld a,0
    ld de, buffer
    call ScoresConvert.ConvertToDecimal
    TEST_STRING_PTR buffer, .expectedString
    nop ; ASSERTION A == 5
    TC_END
.expectedString:
    db "00000",0

;Max 65535
UT_ConvertToDecimal3:
    ld hl,65535
    ld a,0
    ld de, buffer
    call ScoresConvert.ConvertToDecimal
    TEST_STRING_PTR buffer, .expectedString
    nop ; ASSERTION A == 5
    TC_END
.expectedString:
    db "65535",0

; 42
UT_ConvertToDecimal4:
    ld hl,42
    ld a,1
    ld de, buffer
    call ScoresConvert.ConvertToDecimal
    TEST_STRING_PTR buffer, .expectedString
    nop ; ASSERTION A == 2
    TC_END
.expectedString:
    db "42",0

    endmodule
