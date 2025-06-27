    module TestSuite_Exceptions

UT_nullPointer1:
    EXCEPTIONS_CLEAR
    CHECK_NULL_POINTER_NOT_CALLED
    call Exceptions.nullPointer
    CHECK_NULL_POINTER_CALLED
    TC_END

UT_slotNotFound1:
    EXCEPTIONS_CLEAR
    CHECK_SLOT_NOT_FOUND_NOT_CALLED
    call Exceptions.slotNotFound
    CHECK_SLOT_NOT_FOUND_CALLED
    TC_END
    
    endmodule
