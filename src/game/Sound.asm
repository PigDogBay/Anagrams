;-----------------------------------------------------------------------------------
; 
; Module Sound
; 
; Frontend for the game's sound effects and music
; 
; 
; 
; 
;-----------------------------------------------------------------------------------

    module Sound
SFX_BUTTON_CLICK    equ $0000
SFX_CANCEL          equ $0001
SFX_HIGHLIGHT       equ $0002
SFX_SOLVED          equ $0003
SFX_TIME_OUT        equ $0004
SFX_ERROR           equ $0005
SFX_TIMER_LOW       equ $0006
SFX_CHEAT           equ $0007

song1DataPages:  
    defb BANK_SOUND_TRACK1,BANK_SOUND_TRACK1+1,BANK_SOUND_TRACK1+2


init:
    call NextDAW.init
    ret


playTitleMusic:
    ; de        song data pages
    ; a         force AY mono (bits 0,1,2 control AY 1,2,3.  Set to force to mono, otherwise use song default)
    ld de, song1DataPages
    ld a, 0
    call NextDAW._NextDAW_InitSong
    call NextDAW._NextDAW_PlaySong
    ret

slotTile:
    ld hl, SFX_SLOT_TILE
    call NextDAW._NextDAW_PlaySFX
    ret
    


    endmodule