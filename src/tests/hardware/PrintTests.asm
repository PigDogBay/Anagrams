    module TestSuite_Puzzle

; Dezog deug console, memory viewer
;-mv TestSuite_Puzzle.buffer 16
buffer:
    block 64

UT_bufferPrint1:
    ld de, buffer
    ld hl, .sourceString1 : call Print.bufferPrint
    ld hl, .sourceString2 : call Print.bufferPrint
    ld hl, .sourceString3 : call Print.bufferPrint

    TEST_STRING_PTR buffer, .expectedString
    TC_END
.sourceString1
    db "Alien",0
.sourceString2
    db " ",0
.sourceString3
    db "Earth",0
.expectedString:
    db "Alien Earth",0

;Check for null termination
UT_bufferPrint2:
    ld de, buffer
    ld hl, .bigString : call Print.bufferPrint
    ld de, buffer
    ld hl, .littleString : call Print.bufferPrint

    TEST_STRING_PTR buffer, .littleString
    TC_END
.bigString
    db "Hanging Chad",0
.littleString
    db "Balatro",0


    endmodule
