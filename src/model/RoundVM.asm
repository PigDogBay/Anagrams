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
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
onRerollClick:
    call pickDifferentCategory
    ret


;-----------------------------------------------------------------------------------
;  
; Function pickDifferentCategory()
;
; Picks another category that is different to the current category
;
; Dirty: A,BC,DE,HL
;
;-----------------------------------------------------------------------------------
pickDifferentCategory:
    ;Set up a random puzzle
    call Puzzles.newCategory
    call Puzzles.copyRandomPuzzle
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

    ld hl,42
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
