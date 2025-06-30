;-----------------------------------------------------------------------------------
; 
; Module: GameState
; 
; State machine to handle the main phases of the game
; 
;-----------------------------------------------------------------------------------
    module GameStateMachine

;-----------------------------------------------------------------------------------
; 
; Structure: state 
; 
; Contains pointers to a state's functions
; 
;-----------------------------------------------------------------------------------
    struct @stateStruct
enter       word
update      word
    ends

;-----------------------------------------------------------------------------------
; 
; function: change(uint16 newState) 
; 
; Sets the current state to newState and calls the newState.entry()
;
; In: HL pointer to the state struct of the new state
;
; Dirty: ALL
; 
;-----------------------------------------------------------------------------------
change:
    ld (currentState),hl
    ld de,(hl)
    ld hl,de
    jp (hl)


;-----------------------------------------------------------------------------------
; 
; function: update()
; 
; Calls the current state's update function
;
; Dirty: ALL
; 
;-----------------------------------------------------------------------------------
update:
    ; Get ptr to the current state's struct
    ld hl, (currentState)
    ;Move to the enter function 
    inc hl
    inc hl
    ;Get ptr to enter function
    ld de,(hl)
    ld hl,de
    jp (hl)




nullState: 
    stateStruct nullEnter, nullUpdate
nullEnter:
    ret
nullUpdate:
    ret


; 
; Pointer to current state
; 
currentState:
    dw  nullState

    


    endmodule