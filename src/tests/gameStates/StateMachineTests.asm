    module TestSuite_GameStateMachine


testState: 
    stateStruct enter,update

enter:
    ld a,1
    ret

update:
    ld a,2
    ret



UT_change1:
    xor a
    ld hl, testState
    call GameStateMachine.change
    nop ; ASSERTION A == 1
    TC_END


UT_update1:
    ld hl, testState
    call GameStateMachine.change
    ld hl,0
    xor a
    call GameStateMachine.update
    nop ; ASSERTION A == 2
    TC_END


    endmodule