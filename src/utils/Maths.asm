    module Maths

;-----------------------------------------------------------------------------------
;
; Function: divMod
;
; Divides A by B and returns the remainder in A and quotient in B
; It does this by repeated subtraction
; 
; In:  A dividend, B divisor
; Out: A remainder, C quotient (255,255 for division by zero)
;-----------------------------------------------------------------------------------
divMod:
    ;division by 0 check
    ld c,a
    ld a,b
    or a
    jr z, .divisionByZero
    ld a,c

    ld   c, 0       ; Initialize quotient
.loop
    cp   b          ; Compare A with B
    ret  c          ; If A < B, remainder = A, quotient = 0
    sub  b          ; A = A - B
    inc  c          ; Increment quotient
    jr .loop

.divisionByZero:
    ld a,255
    ld c,a
    ret
    endmodule