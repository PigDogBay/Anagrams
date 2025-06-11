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


;--------------------------------------------------------------------------
;
; Function: getRandom
;
; 16bit pseudo random number using the xor shift method 
;
; Based on code by Patricia Curtis:
; https://luckyredfish.com/patricias-z80-snippets/
;
; Out:  hl  pseudorandom number
;
; dirty   none
;--------------------------------------------------------------------------

; seed to start with
randomSeed:          dw  %0101101001100101

getRandom:  
            push af
            ld hl,(randomSeed)     // get the last seed
            ld a,h                 // add high byte register    
            rra                    // rotate right accumulator with carry
            ld a,r                 // adding in the Memory Refresh Register
            add a,l                // now do the same with the low seed byte
            rra                    // rotate right accumulator with carry again
            xor h                  // exclusive or high seed byte with the accumulator 
            ld h,a                 // put the accumulator into the high seed
            ld a,l                 // and put the low seed into the accumulator 
            rra                    // rotate right accumulator with carry again
            ld a,h                 // do the same with the high using the carry from the low
            rra                    // rotate right accumulator with carry again  
            xor l                  // exclusive or low seed byte with the accumulator 
            ld l,a                 // yes store the accumulator in the low seed byte
            xor h                  // exclusive or high seed byte with the accumulator 
            ld h,a                 // now store the accumulator in the high seed byte
            ld (randomSeed),hl     // and store as the next seed
            pop af
            ret  