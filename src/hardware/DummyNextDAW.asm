;-----------------------------------------------------------------------------------
; 
; Module NextDAW
; 
; Dummy Code
; 
; 
; 
; 
;-----------------------------------------------------------------------------------

    module NextDAW


; ASM API
_NextDAW_InitSong          ret
_NextDAW_UpdateSong        ret
_NextDAW_PlaySong          ret
_NextDAW_StopSong          ret
_NextDAW_StopSongHard      ret
_NextDAW_UpdateSongNoAY    ret
_NextDAW_UpdateAY          ret
_NextDAW_InitSystem        ret
_NextDAW_InitSFXBank       ret

; h = bank index [0..3]
; l = sfx index [0...63]
_NextDAW_PlaySFX           ret

_NextDAW_UpdateSFX         ret
_NextDAW_GetPSGDataPtr     ret
_NextDAW_EnablePSGWrite    ret

init:
    ret

update:
    ret

stop:
    ret

    endmodule