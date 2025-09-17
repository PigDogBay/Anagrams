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
    ; next state
;    ld hl, GS_PUZZLE_VIEWER
    ld hl, GS_WIN
    call GameStateMachine.change
    ret



    endmodule