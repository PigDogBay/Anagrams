;-----------------------------------------------------------------------------------
; 
; Module: RoundVM
; 
; View-Model for the Round 'Lecture Notes' screen
; 
;-----------------------------------------------------------------------------------

    module RoundVM


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


    endmodule
