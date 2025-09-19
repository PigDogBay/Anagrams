    module TestSuite_List

;------------------------------------------------------------
; Helpers
;------------------------------------------------------------

; Callback used with foreach: sums each value of A
cb_sum:
    ld b,a
    ld a,(.sum)
    add b
    ld (.sum),a
    ret
.sum: db 0

;------------------------------------------------------------
; Tests
;------------------------------------------------------------

UT_clear_setsCountToZero:
    ld a,42
    ld (List.count),a
    call List.clear
    ld a,(List.count)
    nop ; ASSERTION A==0
    TC_END

UT_append_addsElementAndIncrementsCount:
    call List.clear
    ld a,99
    call List.append
    ld a,(List.count)
    nop ; ASSERTION A==1
    ld a,(List.list+0)
    nop ; ASSERTION A==99
    TC_END

UT_getAt_returnsCorrectElement:
    call List.clear
    ld a,11
    call List.append
    ld a,22
    call List.append
    ld a,1          ; index 1
    call List.getAt
    nop ; ASSERTION B==22
    TC_END


UT_firstIndexOf_findsElement:
    call List.clear
    ld a,10
    call List.append
    ld a,20
    call List.append
    ld a,30
    call List.append

    ld a,20
    call List.firstIndexOf
    nop ; ASSERTION C == 1
    TC_END

UT_firstIndexOf_returnsMinus1WhenNotFound:
    call List.clear
    ld a,77
    call List.append

    ld a,42
    call List.firstIndexOf
    nop ; ASSERTION C == 255
    TC_END

UT_foreach_callsCallbackForEachElement:
    call List.clear
    ld a,1
    call List.append
    ld a,2
    call List.append
    ld a,3
    call List.append

    ld c,0          ; counter
    ld hl,cb_sum
    call List.foreach
    ld a,(cb_sum.sum)
    nop ; ASSERTION A==6
    TC_END

    endmodule
