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


    endmodule
