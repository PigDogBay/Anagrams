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

UT_lenUptoChar1:
    ld hl, .data
    ld a,"."
    call String.lenUptoChar
    nop ; ASSERTION A == 14
    TC_END
.data:
    db "Acorn Electron. Commodore 64.",0

UT_lenUptoChar2:
    ld hl, .data
    ld a,"\n"
    call String.lenUptoChar
    nop ; ASSERTION A == 7
    TC_END
.data:
    db "The Ace\nof Spades.",0

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

;
; Use debugger and watch the string change:
; -mv TestSuite_String.UT_shuffle1.data 16
UT_shuffle1:
    ld hl, .data
    ld b, 10
.loop:
    call String.shuffle
    call String.len
    nop ; ASSERTION A == 10
    djnz .loop
    TC_END
.prefix:
    db ">>>"
.data:
    db "ZXSpectrum",0
.suffix:
    db "<<<"
    TC_END

UT_equals1:
    ld hl, .string1
    ld de, .string2
    ld bc, 0xCAFE
    call String.equals
    TEST_FLAG_Z
    ; Test registers are unchanged
    nop ; ASSERTION HL == TestSuite_String.UT_equals1.string1
    nop ; ASSERTION DE == TestSuite_String.UT_equals1.string2
    nop ; ASSERTION BC == 0xCAFE
    TC_END
.string1:
    db "BBC Micro",0
.string2:
    db "BBC Micro",0

UT_equals2:
    ld hl, .string1
    ld de, .string2
    call String.equals
    TEST_FLAG_NZ
    TC_END
.string1:
    db "BBC Micro",0
.string2:
    db "Commodore",0

UT_equals3:
    ld hl, .string1
    ld de, .string2
    call String.equals
    TEST_FLAG_NZ
    TC_END
.string1:
    db "BBC Micro",0
.string2:
    db "BBC MicroB",0

; Two empty strings are equals
UT_equals4:
    ld hl, .string1
    ld de, .string2
    call String.equals
    TEST_FLAG_Z
    TC_END
.string1:
    db 0
.string2:
    db 0

; string1 is empty
UT_equals5:
    ld hl, .string1
    ld de, .string2
    call String.equals
    TEST_FLAG_NZ
    TC_END
.string1:
    db 0
.string2:
    db "not empty",0

; string2 is empty
UT_equals6:
    ld hl, .string1
    ld de, .string2
    call String.equals
    TEST_FLAG_NZ
    TC_END
.string1:
    db "not empty",0
.string2:
    db 0

    endmodule
