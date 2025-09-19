;-----------------------------------------------------------------------------------
;
; Module Lifelines
; 
; Handles the data, logic and strings for the Linelines
; 
;-----------------------------------------------------------------------------------
    module Lifelines

;-----------------------------------------------------------------------------------
;
; Constants, the default costs for each  lifelines
; 
;-----------------------------------------------------------------------------------
DEFAULT_COST_TILE equ 10
DEFAULT_COST_SLOT equ 20
DEFAULT_COST_RAND equ 5
DEFAULT_COST_CLUE equ 10


;-----------------------------------------------------------------------------------
; 
; Function: reset()
;
; Sets the cost for each lifeline to its default value
;
; 
;-----------------------------------------------------------------------------------
reset:
    ld a,DEFAULT_COST_TILE
    ld (costTile),a
    
    ld a,DEFAULT_COST_SLOT
    ld (costSlot),a
    
    ld a,DEFAULT_COST_RAND
    ld (costRand),a
    
    ld a,DEFAULT_COST_CLUE
    ld (costClue),a
    ret



;-----------------------------------------------------------------------------------
; 
; Function: printCost
;
; Prints the cost to the buffer, eg 'Cost -10s'
;
;  In: A - Cost
;      DE - Buffer
;      HL - Prefix
; Out: DE - points to null terminator
;   
; Dirty: A,DE,HL
; 
;-----------------------------------------------------------------------------------
printCost:
    push af
    ;Prefix
    call Print.bufferPrint

    ;Amount
    pop af
    ld h,0
    ld l,a
    ld a,1
    call ScoresConvert.ConvertToDecimal

    ;Unit
    ;point to the end of the string
    ex de,hl
    add hl,a
    ;Print second units
    ld (hl), 's'
    inc hl
    ;null terminate
    ld (hl), 0
    ex de,hl
    ret

costTile:               db 10
costSlot:               db 20
costRand:               db 5
costClue:               db 10

    endmodule
