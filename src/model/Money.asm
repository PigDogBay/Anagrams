;-----------------------------------------------------------------------------------
; Module Money
;
; Handles player's money and difficulty setting
;
; Function: getDifficulty() -> uint8
; Function: getDifficultyName() -> uint16
; Function: previousDifficulty() -> uint8
; Function: nextDifficulty() -> uint8
;
; Function: getMoney() -> uint16
; Function: resetMoney()
; Function: debitMoney(uint16 debit) -> uint16
; Function: creditMoney(uint16 credit) -> uint16
; Function: topUpMoney() -> uint16
; 
;-----------------------------------------------------------------------------------
    module Money

ENUM_DIFFICULTY_EASY:   equ 0
ENUM_DIFFICULTY_NORMAL: equ 1
ENUM_DIFFICULTY_HARD:   equ 2
DIFFICULTY_COUNT:       equ 3

MONEY_EASY:   equ 1200
MONEY_NORMAL: equ 900
MONEY_HARD:   equ 600


;-----------------------------------------------------------------------------------
; 
; Function: getDifficulty() -> uint8
;
; Getter for difficulty enum value
;
; Out: A = ENUM_DIFFICULTY_EASY, _NORMAL or _HARD
; 
;-----------------------------------------------------------------------------------
getDifficulty:
    ld a,(difficulty)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getDifficultyName() -> uint16
;
; Getter for difficulty description string
;
; Out: HL = pointer to difficulty desciption string 
; 
;-----------------------------------------------------------------------------------
getDifficultyName:
    ld a,(difficulty)
    ld hl, normalStr
    cp ENUM_DIFFICULTY_NORMAL
    jr z, .exit
    ld hl, hardStr
    cp ENUM_DIFFICULTY_HARD
    jr z, .exit
    ld hl, easyStr
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: previousDifficulty() -> uint8
;
; Sets and returns previous difficulty settinge, will wrap round to ENUM_DIFFICULTY_HARD
;
; Out: A = previous difficulty setting (ENUM_DIFFICULTY_ )
; 
;-----------------------------------------------------------------------------------
previousDifficulty:
    ld a,(difficulty)
    or a
    jr nz, .noWrapAround
    ld a, DIFFICULTY_COUNT
.noWrapAround:
    dec a
    ld (difficulty),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextDifficulty() -> uint8
;
; Sets and returns next difficulty settings, will wrap round to ENUM_DIFFICULTY_EASY
;
; Out: A = next difficulty setting (ENUM_DIFFICULTY_ )
; 
;-----------------------------------------------------------------------------------
nextDifficulty:
    ld a,(difficulty)
    inc a
    cp DIFFICULTY_COUNT
    jr nz, .noWrapAround
    xor a
.noWrapAround:
    ld (difficulty),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getMoney() -> uint16
;
; Getter for money the player has
;
; Out: HL = money
; 
;-----------------------------------------------------------------------------------
getMoney:
    ld hl,(money)
    ret

;-----------------------------------------------------------------------------------
; 
; Function: resetMoney()
;
; Sets the money based on difficulty setting, call this at the start of a new game
;
; Dirty: A, HL
; 
;-----------------------------------------------------------------------------------
resetMoney:
    ld a,(difficulty)
    ld hl,MONEY_NORMAL
    cp ENUM_DIFFICULTY_NORMAL
    jr z, .exit
    ld hl,MONEY_HARD
    cp ENUM_DIFFICULTY_HARD
    jr z, .exit
    ld hl,MONEY_EASY
.exit:
    ld (money),hl
    ret

;-----------------------------------------------------------------------------------
; 
; Function: debitMoney(uint16 debit) -> uint16
;
; Decreases money the student has by the debit
;
; In:  DE = Amount to debit
; Out: nc HL = current balance of money 
;      carry set: card refused, unable to purchase item
;-----------------------------------------------------------------------------------
debitMoney:
    ld hl,(money)
    or a
    sbc hl,de
    jr c, .exit
    ld (money),hl
.exit:
    ret

;-----------------------------------------------------------------------------------
; 
; Function: creditMoney(uint16 credit) -> uint16
;
; Increases money the student has by the credit
;
; In:  DE = Amount to credit
; Out: HL = current balance of money 
; 
;-----------------------------------------------------------------------------------
creditMoney:
    ld hl,(money)
    add hl,de
    ld (money),hl
    ret

;-----------------------------------------------------------------------------------
; 
; Function: topUpMoney() -> uint16
;
; Adds another year's worth of student grant to the balance
;
; Out: HL = current balance of money 
;
; Dirty: A, DE
; 
;-----------------------------------------------------------------------------------
topUpMoney:
    ld a,(difficulty)
    ld de,MONEY_NORMAL
    cp ENUM_DIFFICULTY_NORMAL
    jr z, .exit
    ld de,MONEY_HARD
    cp ENUM_DIFFICULTY_HARD
    jr z, .exit
    ld de,MONEY_EASY
.exit:
    ld hl,(money)
    add hl,de
    ld (money),hl
    ret



;-----------------------------------------------------------------------------------
; 
; Function: printToBuffer()
;
; Prints the money to the Print.buffer, prefixes '£' and appends spaces to clear screen debris
;
; Out: HL - points to null terminator
;   
; Dirty: A,DE,HL
; 
;-----------------------------------------------------------------------------------
printToBuffer:
    ld hl, Print.buffer
    ld (hl), 96  ; £ symbol
    inc hl
    ex de,hl

    ld hl,(Money.money)
    ld a,1
    call ScoresConvert.ConvertToDecimal

    ;point to the end of the string
    ex de,hl
    add hl,a

    ;pad with spaces (to clear printing area on the screen)
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ld (hl), ' '
    inc hl
    ;null terminate
    ld (hl), 0

    ret


; ` is ASCII value for £
easyStr:    db "Student Loan `12,000 (Easy)",0
normalStr:  db "Bursary `9,000 (Normal)",0
hardStr:    db "Scholarship `6,000 (Hard)",0


difficulty:
    db ENUM_DIFFICULTY_NORMAL

money:
    dw 0

    endmodule
