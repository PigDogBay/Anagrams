;-----------------------------------------------------------------------------------
; 
; Exceptions is a mock replacement enable unit tests to check if an exception 
; has been called.
; 
; 
; 
; 
; 
;-----------------------------------------------------------------------------------

    module Exceptions

    macro EXCEPTIONS_CLEAR
        xor A
        ld (Exceptions.nullPointer.callFlag),a
        ld (Exceptions.slotNotFound.callFlag),a
        ld (Exceptions.tileNotFound.callFlag),a
    endm

    macro CHECK_NULL_POINTER_CALLED
        ld a, (Exceptions.nullPointer.callFlag)
        nop ; ASSERTION A == 1
    endm

    macro CHECK_NULL_POINTER_NOT_CALLED
        ld a, (Exceptions.nullPointer.callFlag)
        nop ; ASSERTION A == 0
    endm

    macro CHECK_SLOT_NOT_FOUND_CALLED
        ld a, (Exceptions.slotNotFound.callFlag)
        nop ; ASSERTION A == 1
    endm

    macro CHECK_SLOT_NOT_FOUND_NOT_CALLED
        ld a, (Exceptions.slotNotFound.callFlag)
        nop ; ASSERTION A == 0
    endm

    macro CHECK_TILE_NOT_FOUND_CALLED
        ld a, (Exceptions.tileNotFound.callFlag)
        nop ; ASSERTION A == 1
    endm

    macro CHECK_TILE_NOT_FOUND_NOT_CALLED
        ld a, (Exceptions.tileNotFound.callFlag)
        nop ; ASSERTION A == 0
    endm

nullPointer:
    ld a,1
    ld (.callFlag),a
    ret
.callFlag:
    db 0

slotNotFound:
    ld a,1
    ld (.callFlag),a
    ret
.callFlag:
    db 0

tileNotFound:
    ld a,1
    ld (.callFlag),a
    ret
.callFlag:
    db 0




    endmodule