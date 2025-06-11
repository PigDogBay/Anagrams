    module TestSuite_String


UT_len1:
    ld hl, .data
    call String.len
    nop ; ASSERTION A == 14
    TC_END
.data:
    db "Acorn Electron",0

; Zero length string
UT_len2:
    ld hl, .data
    call String.len
    nop ; ASSERTION A == 0
    TC_END
.data:
    db 0

;String > 255 bytes
UT_len3:
    ld hl, .data
    call String.len
    nop ; ASSERTION A == 255
    TC_END
.data:
    block 256,42

;String is 253 bytes
UT_len4:
    ld hl, .data
    call String.len
    nop ; ASSERTION A == 253
    TC_END
.data:
    block 253,'A'
    db 0



UT_swap1:
    ld hl, .data
    ld a,4  ;[4] = n
    ld b,9  ;[9] = c
    call String.swap
    TEST_STRING_PTR .data,.expected
    TC_END
.data:
    db "acorn electron",0
.expected:
    db "acorc elentron",0

;Same
UT_swap2:
    ld hl, .data
    ld a,5  ;[5]
    ld b,5  ;[5]
    call String.swap
    TEST_STRING_PTR .data,.expected
    TC_END
.data:
    db "acorn electron",0
.expected:
    db "acorn electron",0

UT_swap3:
    ld hl, .data
    ld a,0  ;[0]
    ld b,13  ;[13]
    call String.swap
    TEST_STRING_PTR .data,.expected
    TC_END
.data:
    db "acorn electron",0
.expected:
    db "ncorn electroa",0


UT_shuffle1:
    TC_END
.data:
    db "acorn"





    endmodule
