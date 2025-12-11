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
    L2_SET_IMAGE IMAGE_MICHAELMAS
    call NextSprite.removeAll
    call SpriteList.removeAll

    ret

update:
    ld a, College.CHRISTMAS_COLLEGE
    ld (College.college),a
    ld hl, GS_WIN
    call GameStateMachine.change
    ret


    endmodule