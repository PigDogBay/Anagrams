    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Sprite


UT_mouse_over:
    ld a,42
    nop ; ASSERTION A == 42
    TEST_MEMORY_BYTE sprite.list,0
    TC_END

    endmodule