;-----------------------------------------------------------------------------------
; Module YearTerm
;
; Handles the Year and Term
;
; Function: select(uint8 year, uint8 term)
; Function: nextTerm()
; Function: nextYear()
; Function: isGameOver() -> Boolean
;
; Function: getTerm() -> uint8
; Function: getTermName() -> uint16
; Function: getShortTermName() -> uint16
;
; Function: getYear() -> uint8
; Function: previousYearSelect() -> uint8
; Function: nextYearSelect() -> uint8
; Function: getYearName() -> uint16
; Function: getShortYearName() -> uint16
;
;-----------------------------------------------------------------------------------
    module YearTerm

FIRST_TERM:    equ 1
LAST_TERM:     equ 3
LAST_YEAR:     equ 8

;-----------------------------------------------------------------------------------
; 
; Function: select(uint8 year, uint8 term)
;
; Sets the year and term. If term or year is invalid, yr 1, term 1 is set
;
; In: H = Year
;     L = Term 
; 
;-----------------------------------------------------------------------------------
select:
    ;Validation, 0 check
    ld a, h
    or a
    jr z, .failed
    ;Max year
    cp a, LAST_YEAR + 1
    jr nc, .failed
    
    ld a, l
    or a
    jr z, .failed
    ;Greater than last term
    cp a, LAST_TERM + 1
    jr nc, .failed

    ; term = l,year = h
    ld (term),hl
    ret

;Gracefully fail by selecting year 1, term 1
.failed:
    ld hl,$0101
    ld (term),hl
    ret


;-----------------------------------------------------------------------------------
; 
; Function: nextTerm()
;
; Each year has 3 terms, this function increase the current term
;
; Out: A = term (1,2,3) or 0 if no more terms (call nextYear())
; 
;-----------------------------------------------------------------------------------
nextTerm:
    ld a,(term)
    inc a
    ld (term),a
    cp LAST_TERM+1
    jr nc, .noMoreTerms
    ret
.noMoreTerms:
    xor a
    ret
;-----------------------------------------------------------------------------------
; 
; Function: nextYear()
;
; Increase the year, term is set to 1 
;
; Out: A = Year (1,2, ...) or 0 if no more years (Game Completed)
; 
;-----------------------------------------------------------------------------------
nextYear:
    ;set round to 1
    ld a,FIRST_TERM
    ld (term),a

    ld a,(year)
    inc a
    ld (year),a
    cp LAST_YEAR+1
    jr nc, .noMoreYears
    ret
.noMoreYears:
    xor a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: isGameOver() -> Boolean
;
; Checks if more years are left, call this function after nextYear()
;
; Out: Z nz = game over, z = current year is valid to play 
;    
; Dirty: A 
; 
;-----------------------------------------------------------------------------------
isGameOver:
    ld a,(year)
    cp LAST_YEAR+1
    jr c, .false 
    ; Reset zero flag to indicate TRUE
    ld a,1
    or a
    ret
.false:
    ;Set zero flag. to indicate FALSE
    xor a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getTerm() -> uint8
;
; Getter for current term
;
; Out: A = current term
; 
;-----------------------------------------------------------------------------------
getTerm:
    ld a,(term)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getTermName() -> uint16
;
; Getter for current term name
;
; Out: HL = pointer to term's name string 
; 
;-----------------------------------------------------------------------------------
getTermName:
    ld a,(term)
    ld hl, termNameStr2
    cp 2
    jr z, .exit
    ld hl, termNameStr3
    cp 3
    jr z, .exit
    ld hl, termNameStr1
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getShortTermName() -> uint16
;
; Getter for current term's short name
;
; Out: HL = pointer to term's short name string 
; 
;-----------------------------------------------------------------------------------
getShortTermName:
    ld a,(term)
    ld hl, romanII
    cp 2
    jr z, .exit
    ld hl, romanIII
    cp 3
    jr z, .exit
    ld hl, romanI
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getYear() -> uint8
;
; Getter for current year
;
; Out: A = current year
; 
;-----------------------------------------------------------------------------------
getYear:
    ld a,(year)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: previousYearSelect() -> uint8
;
; Sets and returns previous year value, will wrap round to LAST_YEAR
;
; Out: A = previous year value 
; 
;-----------------------------------------------------------------------------------
previousYearSelect:
    ld a,(year)
    dec a
    jr nz, .noWrapAround
    ld a, LAST_YEAR
.noWrapAround:
    ld (year),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextYearSelect() -> uint8
;
; Sets and returns next year value, will wrap round to year 1
;
; Out: A = next year value 
; 
;-----------------------------------------------------------------------------------
nextYearSelect:
    ld a,(year)
    inc a
    cp LAST_YEAR + 1
    jr nz, .noWrapAround
    ;Wrap round to yr 1
    ld a,1
.noWrapAround:
    ld (year),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getYearName() -> uint16
;
; Getter for current year name
;
; Out: HL = current year name
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
getYearName:
    push de
    ld a,(year)
    ; Subtract 1 as year starts at 1
    dec a
    ld hl, yearNameJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    pop de
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getShortYearName() -> uint16
;
; Getter for current year's short name
;
; Out: HL = current year's short name
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
getShortYearName:
    push de
    ld a,(year)
    ; Subtract 1 as year starts at 1
    dec a
    ld hl, romanJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    pop de
    ret


;-----------------------------------------------------------------------------------
; 
; Function: printToBuffer(uint16 buffer)
;
; Prints the Year.Term to the buffer
;
;  In: DE - buffer pointer
; Out: DE - points to null terminator
;   
; Dirty: A,DE,HL
; 
;-----------------------------------------------------------------------------------
printToBuffer:
    call YearTerm.getShortYearName
    call Print.bufferPrint

    ld hl, .delimiter
    call Print.bufferPrint

    call YearTerm.getTermName
    call Print.bufferPrint
    ret
.delimiter:
    db ". ",0


termNameStr1: db "MICHAELMAS",0
termNameStr2: db "HILARY",0
termNameStr3: db "TRINITY",0

romanJumpTable:
    dw romanI
    dw romanII
    dw romanIII
    dw romanIV
    dw romanV
    dw romanVI
    dw romanVII
    dw romanVIII
    dw romanIX
    dw romanX
    
romanI : db "I",0
romanII : db "II",0
romanIII : db "III",0
romanIV : db "IV",0
romanV : db "V",0
romanVI : db "VI",0
romanVII : db "VII",0
romanVIII : db "VIII",0
romanIX : db "IX",0
romanX : db "X",0

yearNameJumpTable:
    dw yearNameStr1
    dw yearNameStr2
    dw yearNameStr3
    dw yearNameStr4
    dw yearNameStr5
    dw yearNameStr6
    dw yearNameStr7
    dw yearNameStr8

yearNameStr1: db "Fresher (Yr 1)",0
yearNameStr2: db "Sophomore (Yr 2)",0
yearNameStr3: db "Finals (Yr 3)",0
yearNameStr4: db "Masters (Yr 4)",0
yearNameStr5: db "DPhil (Yr 5)",0
yearNameStr6: db "DPhil (Yr 6)",0
yearNameStr7: db "DPhil (Yr 7)",0
yearNameStr8: db "Professorship (Yr 8)",0


term:
    db 1

year:
    db 1

    endmodule
