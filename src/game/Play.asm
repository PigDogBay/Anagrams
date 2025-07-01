;-----------------------------------------------------------------------------------
; 
; State: play
; 
; Player drags tiles
; 
;-----------------------------------------------------------------------------------

    module GameState_Play

@GS_PLAY:
    stateStruct enter,update


enter:
    ret

update:
    call Game.updateMouse
    call MouseListener.update
    call Game.updateSprites
    ret


    endmodule