    module Maths

;-----------------------------------------------------------------------------------
;
; Function: divMod(uint8,uint8) -> uint8,uint8
;
; Divides A by B and returns the remainder in A and quotient in B
; It does this by repeated subtraction
; 
; In:  A dividend, B divisor
; Out: A remainder = A MOD B, C quotient = A/B 
;      255,255 for division by zero
;
; Dirty: A, BC
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


;--------------------------------------------------------------------------
;
; Function: getRandom() -> uint16
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



;--------------------------------------------------------------------------
;
; Function: rnd(uint8: max) -> uint8
;
; Returns a random number from 0 to max - 1
;
; In:  A  max
; Out: A random value from 0 to max-1
;
; Dirty: A
;
;--------------------------------------------------------------------------
rnd:
    push bc
    push hl
    ;Get random number in HL
    call getRandom
    ;Divisor
    ld b,a
    ;Dividend - combine 16bit random value into 8 bits
    ld a,h
    xor l
    ;Returns remainder A
    call divMod
    pop hl
    pop bc
    ret




;--------------------------------------------------------------------------
;
; Function: difference(uint8 val1, uint8 val2) -> uint8
;
; Find the absolute difference between 2 8-bit values
;
; In: D - value 1
;     E - value 2
; Out: A = abs(value 1 - value 2)
;
;--------------------------------------------------------------------------
difference:
    ld a,d
    sub e
    jr nc, .done
    neg
.done:
    ret 




    endmodule
