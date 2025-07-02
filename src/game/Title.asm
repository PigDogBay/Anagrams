;-----------------------------------------------------------------------------------
; 
; State: Title
; 
; Shows title screen
; 
;-----------------------------------------------------------------------------------

    module GameState_Title

@GS_TITLE: 
    stateStruct enter,update


enter:
    call NextSprite.removeAll
    call SpriteList.removeAll
    ld a,5
    call Graphics.fillLayer2_320
    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouse
    call Game.updateSprites
    ret


    endmodule