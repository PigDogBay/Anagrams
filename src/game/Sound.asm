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
SFX_ERROR           equ $0003
SFX_CHEAT           equ $0004
SFX_TIMER_LOW       equ $0005
SFX_SOLVED          equ $0006

song1DataPages:  
    defb BANK_SOUND_TRACK1,BANK_SOUND_TRACK1+1
song2DataPages:  
    defb BANK_SOUND_TRACK2,BANK_SOUND_TRACK2+1
song3DataPages:  
    defb BANK_SOUND_TRACK3,BANK_SOUND_TRACK3+1
song4DataPages:  
    defb BANK_SOUND_TRACK4,BANK_SOUND_TRACK4+1


init:
    call NextDAW.init
    ret


playTitleMusic:
    call NextDAW.stop
    ; de        song data pages
    ; a         force AY mono (bits 0,1,2 control AY 1,2,3.  Set to force to mono, otherwise use song default)
    ld de, song4DataPages
    ld a, 0
    call NextDAW._NextDAW_InitSong
    call NextDAW._NextDAW_PlaySong
    ret

playSolvedMusic:
    call NextDAW.stop
    ; de        song data pages
    ; a         force AY mono (bits 0,1,2 control AY 1,2,3.  Set to force to mono, otherwise use song default)
    ld de, song2DataPages
    ld a, 0
    call NextDAW._NextDAW_InitSong
    call NextDAW._NextDAW_PlaySong
    ret

playDroppedOutMusic:
    call NextDAW.stop
    ; de        song data pages
    ; a         force AY mono (bits 0,1,2 control AY 1,2,3.  Set to force to mono, otherwise use song default)
    ld de, song3DataPages
    ld a, 0
    call NextDAW._NextDAW_InitSong
    call NextDAW._NextDAW_PlaySong
    ret

playGrangeHill:
    call NextDAW.stop
    ; de        song data pages
    ; a         force AY mono (bits 0,1,2 control AY 1,2,3.  Set to force to mono, otherwise use song default)
    ld de, song1DataPages
    ld a, 0
    call NextDAW._NextDAW_InitSong
    call NextDAW._NextDAW_PlaySong
    ret

buttonClicked:
    ld hl, SFX_CANCEL
    call NextDAW._NextDAW_PlaySFX
    ret

cancel:
    ld hl, SFX_BUTTON_CLICK
    call NextDAW._NextDAW_PlaySFX
    ret

highlight:
    ld hl, SFX_HIGHLIGHT
    call NextDAW._NextDAW_PlaySFX
    ret
error:
    ld hl, SFX_ERROR
    call NextDAW._NextDAW_PlaySFX
    ret
cheat:
    ld hl, SFX_CHEAT
    call NextDAW._NextDAW_PlaySFX
    ret
timerLow:
    ld hl, SFX_TIMER_LOW
    call NextDAW._NextDAW_PlaySFX
    ret
solved:
    ld hl, SFX_SOLVED
    call NextDAW._NextDAW_PlaySFX
    ret



    endmodule