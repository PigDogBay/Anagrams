    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Grid

UT_isSlot1:
    call GameId.reset
    call GameId.nextSlotId
    call GameId.isSlot
    TEST_FLAG_NZ
    call GameId.isTile
    TEST_FLAG_Z
    call GameId.isButton
    TEST_FLAG_Z
    TC_END

UT_isTile1:
    call GameId.reset
    call GameId.nextTileId
    call GameId.isSlot
    TEST_FLAG_Z
    call GameId.isTile
    TEST_FLAG_NZ
    call GameId.isButton
    TEST_FLAG_Z
    TC_END

UT_isButton1:
    call GameId.reset
    ld a, QUIT_BUTTON
    call GameId.isSlot
    TEST_FLAG_Z
    call GameId.isTile
    TEST_FLAG_Z
    call GameId.isButton
    TEST_FLAG_NZ
    TC_END
    endmodule
