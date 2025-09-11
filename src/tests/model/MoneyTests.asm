    module TestSuite_Money


; Function: getDifficulty() -> uint8
; Function: getDifficultyName() -> uint16
; Function: previousDifficulty() -> uint8
; Function: nextDifficulty() -> uint8
UT_difficulty1:
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.getDifficultyName
    TEST_STRING_PTR hl, Money.normalStr

    call Money.previousDifficulty
    call Money.getDifficultyName
    TEST_STRING_PTR hl, Money.easyStr

    TC_END

UT_difficultyWrap1:
    ld a, Money.ENUM_DIFFICULTY_EASY
    ld (Money.difficulty), a
    call Money.previousDifficulty
    call Money.getDifficulty
    nop ; ASSERTION A == Money.ENUM_DIFFICULTY_HARD
    TC_END

UT_difficultyWrap2:
    ld a, Money.ENUM_DIFFICULTY_HARD
    ld (Money.difficulty), a
    call Money.nextDifficulty
    call Money.getDifficulty
    nop ; ASSERTION A == Money.ENUM_DIFFICULTY_EASY
    TC_END

; Function: getMoney() -> uint16
; Function: resetMoney()
; Function: debitMoney(uint16 debit) -> uint16
; Function: creditMoney(uint16 credit) -> uint16
; Function: topUpMoney() -> uint16

UT_resetMoney1
    ld a, Money.ENUM_DIFFICULTY_EASY
    ld (Money.difficulty), a
    call Money.resetMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_EASY
    TC_END
UT_resetMoney2
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL
    TC_END
UT_resetMoney3
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL
    TC_END

UT_debitMoney1
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    ld de,500
    call Money.debitMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL - 500
    TC_END

UT_debitMoney2
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    ld de,3000
    call Money.debitMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL
    TC_END

UT_creditMoney1
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    ld de,500
    call Money.creditMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL + 500
    TC_END

UT_topUpMoney1
    ld a, Money.ENUM_DIFFICULTY_NORMAL
    ld (Money.difficulty), a
    call Money.resetMoney
    call Money.topUpMoney
    call Money.getMoney
    nop ; ASSERTION HL == Money.MONEY_NORMAL * 2
    TC_END


    endmodule
