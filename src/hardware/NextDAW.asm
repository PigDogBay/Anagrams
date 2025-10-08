;-----------------------------------------------------------------------------------
; 
; Module NextDAW
; 
; Wrapper for the NextDAW API
; 
; 
; 
; 
;-----------------------------------------------------------------------------------

    module NextDAW


; ASM API
_NextDAW_PlayerAddr        equ $E000                        ; Driver code address
_NextDAW_InitSong          equ _NextDAW_PlayerAddr+(3*0)    ; Initialize/set song to play.
_NextDAW_UpdateSong        equ _NextDAW_PlayerAddr+(3*1)    ; Call once per frame (NextDAW will automatically update at either 50Hz or 60Hz, depending on the Next's configuration).
_NextDAW_PlaySong          equ _NextDAW_PlayerAddr+(3*2)    ; Start song.
_NextDAW_StopSong          equ _NextDAW_PlayerAddr+(3*3)    ; Stop song - update must still be called each frame as the notes will not release otherwise.
_NextDAW_StopSongHard      equ _NextDAW_PlayerAddr+(3*4)    ; Stop song and cut off voices immediately.
_NextDAW_UpdateSongNoAY    equ _NextDAW_PlayerAddr+(3*5)
_NextDAW_UpdateAY          equ _NextDAW_PlayerAddr+(3*6)
_NextDAW_InitSystem        equ _NextDAW_PlayerAddr+(3*7)
_NextDAW_InitSFXBank       equ _NextDAW_PlayerAddr+(3*8)

; h = bank index [0..3]
; l = sfx index [0...63]
_NextDAW_PlaySFX           equ _NextDAW_PlayerAddr+(3*9)

_NextDAW_UpdateSFX         equ _NextDAW_PlayerAddr+(3*10)
_NextDAW_GetPSGDataPtr     equ _NextDAW_PlayerAddr+(3*11)
_NextDAW_EnablePSGWrite    equ _NextDAW_PlayerAddr+(3*12)   ; a: 0 = disable, 1 = enable

init:
    ; Init NextDAW
    ; l         mmu1
    ; h         mmu2
    ; c         mmu3
    ld l, 0
    ld h, 1
    ld c, 2
;    call _NextDAW_InitSystem

    ; Init sfx bank 0
    ; c         bank index
    ; b         sfx bank data page
    ; de        sfx bank data ptr
    ld c, 0
    ld b, BANK_SOUND_EFFECTS
    ld de, 0
 ;   call _NextDAW_InitSFXBank
    di
    ret

update:
;    call _NextDAW_UpdateSong
 ;   call _NextDAW_UpdateSFX
    di
    ret

stop:
  ;  call _NextDAW_StopSongHard
   ; call _NextDAW_UpdateSong
    di
    ret

    endmodule