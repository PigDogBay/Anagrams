;-----------------------------------------------------------------------------------
; 
; State: Battleground
; 
; Test state for trying out code
; 
;-----------------------------------------------------------------------------------

    module GameState_Battleground

@GS_BATTLEGROUND: 
    stateStruct enter,update


enter:
    ret

update:
    ld hl, GS_PUZZLE_VIEWER
    call GameStateMachine.change
    ret


    endmodule