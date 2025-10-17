    module Maths

;-----------------------------------------------------------------------------------
;
; Struct: rectStruct 
;
; Parameters for a rectangle
;
; x1, y1, x2, y2
;
;-----------------------------------------------------------------------------------
    struct @rectStruct
x1          byte
y1          byte
x2          byte
y2          byte
    ends


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


;-----------------------------------------------------------------------------------
;
; Function: divMod(uint16 A, uint8 B) -> uint16
;
; Divides A by B and returns the result
; It does this by repeated subtraction
; 
; In:  HL dividend
;      E divisor
;
; Out: BC result
;
; Dirty: A, BC, D
;-----------------------------------------------------------------------------------
div16_8:
    ld bc,-1
    ld a,e
    or a
    ret z
    cp 1
    jr z, .divideBy1
    cp 2
    jr z, .divideBy2
    cp 4
    jr z, .divideBy4
    cp 8
    jr z, .divideBy8
    ld d,0
.loop:
    sbc hl,de
    inc bc
    jr nc, .loop
    ret
.divideBy8:
    ;0 -> 7-0 -> CF
    srl h
    ;CF -> 7-0 -> CF
    rr l
.divideBy4:
    srl h
    rr l
.divideBy2:
    srl h
    rr l
.divideBy1:
    ld bc,hl
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
; In:  D - val1
;      E - val2
;
; Out: A = abs(val1 - val2)
;
; Dirty A
;
;--------------------------------------------------------------------------
difference:
    ld a,d
    sub e
    jr nc, .done
    neg
.done:
    ret 

;--------------------------------------------------------------------------
;
; Function: difference(uint16 val1, uint16 val2) -> uint16
;
; Find the absolute difference between 2 8-bit values
;
; In:  HL - val1
;      DE - val2
; 
; Out: HL = abs(val1 - val2)
;
; Dirty A
;
;
;--------------------------------------------------------------------------
difference16:
    ; Clear carry flag
    or    a
    sbc   hl, de
    ; If carry, result is negative
    jr c, negate  
    ret

;--------------------------------------------------------------------------
;
; Function: negate(uint16 val) -> uint16
;
; Negates the 16bit value
;
; In:  HL = val
; 
; Out: HL = -val
;
; Dirty A
;
;--------------------------------------------------------------------------
negate:
    xor   a         ; Clear A
    sub   l         ; A = 0 - L
    ld    l, a      ; L = -L
    sbc   a, a      ; A = 0 - carry (effectively -H if carry was set)
    sub   h         ; A = -H
    ld    h, a      ; H = -H
    ret




    endmodule
