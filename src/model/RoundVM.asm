;-----------------------------------------------------------------------------------
; 
; Module: RoundVM
; 
; View-Model for the Round 'Lecture Notes' screen
; 
;-----------------------------------------------------------------------------------

    module RoundVM

DEFAULT_REROLL_COST         equ 20
DEFAULT_REROLL_COST_INC     equ 5
MAX_REROLL_COST             equ 50
MINIMUM_TIME_FOR_REROLL     equ 30

;-----------------------------------------------------------------------------------
;  
; Function init()
;
; Call this when entering the Round screen to to set up the game variables
;
;-----------------------------------------------------------------------------------
init:
    call GamePhases.roundStart
    call resetReroll
    ret


;-----------------------------------------------------------------------------------
;  
; Function resetReroll()
;
; Resets the reroll cost to the initial value
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
resetReroll:
    ld a, (rerollInitialCost)
    ld (rerollCost),a
    ret


;-----------------------------------------------------------------------------------
;  
; Function onRerollClick()
;
; Handles the reroll button click event
;
; Out: A = 0, no reroll. A = 1, reroll successfull
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
onRerollClick:
    ;is Time above the minimum threshold?
    ld hl, (Time.time)
    ld de, MINIMUM_TIME_FOR_REROLL
    xor a       ;Clear carry flag
    sbc hl,de
    jr c, .noReroll

    ;Pick a different category
    call Puzzles.newCategory
    call Puzzles.copyRandomPuzzle
    ld a,(rerollCost)
    call Time.deduct

    ;Can increase cost of rerolls?
    ld a,(rerollCost)
    cp MAX_REROLL_COST
    jr z, .exit

    ;Increase reroll cost
    ld a,(rerollCostInc)
    ld b,a
    ld a,(rerollCost)
    add b
    ld (rerollCost),a

.exit:
    ld a,1  ;Success
    ret

.noReroll:
    xor a
    ret


;-----------------------------------------------------------------------------------
;  
; Function printStartingTime()
;
; Prints the starting time to the buffer
;
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
printStartingTime:
    ld de, Print.buffer
    ;Prefix
    ld hl,.prefix
    call Print.bufferPrint
    ld hl,(Time.time)
    ld a,1
    call ScoresConvert.ConvertToDecimal
    ;point to the end of the string
    ex de,hl
    add hl,a
    ;Print second units
    ld (hl), 's'
    inc hl
    ;null terminate
    ld (hl), 0
    ret
.prefix db "TIME: ",0


;-----------------------------------------------------------------------------------
;  
; Function printRerollTip()
;
; Prints the reroll tip to the buffer
;
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
printRerollTip:
    ld de,Print.buffer
    ld hl, .prefix
    call Print.bufferPrint

    ld h,0
    ld a,(rerollCost)
    ld l,a
    call Print.bufferPrintNumber

    ld hl, .suffix
    call Print.bufferPrint
    ret
.prefix db "REROLL -",0
.suffix db "s",0

rerollInitialCost:      db DEFAULT_REROLL_COST
rerollCost:             db DEFAULT_REROLL_COST
rerollCostInc:          db DEFAULT_REROLL_COST_INC

    endmodule
