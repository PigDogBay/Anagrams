;-----------------------------------------------------------------------------------
; 
; Module Keyboard
; 
; Keyboard is read from port $xxFE, where xx specifies which set of 5 keys to read.
; Returned read value, check bits 4 to 0, if a bit is cleared then the key is pressed.
; 
; Further info, see p 117 of the ZX Spectrum Next Assembly Developer Guide.
; 
;-----------------------------------------------------------------------------------

    module Keyboard

; ULA control port high bytes
; Each port scans 5 particular keys
; Bits: KEYS_4_3_2_1_0
KEYS_B_N_M_SYMB_SPACE               equ $7f
KEYS_H_J_K_L_ENTER                  equ $bf
KEYS_Y_U_I_O_P                      equ $df
KEYS_6_7_8_9_0                      equ $ef
KEYS_5_4_3_2_1                      equ $f7
KEYS_T_R_E_W_Q                      equ $fb
KEYS_G_F_D_S_A                      equ $fd
KEYS_V_C_X_Z_CAPS                   equ $fe


;-----------------------------------------------------------------------------------
; 
; Function update() 
; 
; 
; For now the function is a debugging aid and will break when SPACE is pressed
; 
; 
;-----------------------------------------------------------------------------------
update:
    ld a,KEYS_B_N_M_SYMB_SPACE
    in a,(ULA_CONTROL_PORT)
    bit 0, a
    jr nz, .not_pressed
    nop
    nop
.not_pressed:
    ret

    endmodule
