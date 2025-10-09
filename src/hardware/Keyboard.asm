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

KEYS_BIT_MASK equ %00011111
KEY_SYM_SHIFT equ 1
KEY_ENTER     equ 2
KEY_CAPS      equ 3

keys: 
    db "BNM",KEY_SYM_SHIFT," "
    db "HJKL",KEY_ENTER
    db "YUIOP"
    db "67890"
    db "54321"
    db "TREWQ"
    db "GFDSA"
    db "VCXZ",KEY_CAPS

;20ms steps for 50hz
KEY_REPEAT_DURATION                 equ 25


repeatTimer:
    timingStruct 0,0,0
;Stores last keypress to check if key is held down
repeatKey:
    db $ff

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
    call NextDAW.stop
    nop
    nop
.not_pressed:
    ret


;-----------------------------------------------------------------------------------
; 
; Function getChar() -> uint8
;  
; Scans the entire keyboard, returns the first key press detected (does not handle multi-key press)
; 
; Returns A = 0, no key pressed otherwise the keys ASCII value
; 
;-----------------------------------------------------------------------------------
getChar:
    ld d,0
    ld a,KEYS_B_N_M_SYMB_SPACE
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_H_J_K_L_ENTER
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_Y_U_I_O_P
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_6_7_8_9_0
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_5_4_3_2_1
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_T_R_E_W_Q
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_G_F_D_S_A
    call checkKey
    or a
    jr nz, .keyPressed

    inc d
    ld a,KEYS_V_C_X_Z_CAPS
    call checkKey
    or a
    jr nz, .keyPressed
    ;No key pressed
    ret

.keyPressed:
    ;map hl to char in keys table
    ; D = table row
    ; E = table column
    ld hl, keys
    ld a,d
    or a
    jr z, .row0

    ld b,d
.add5Loop:
    add hl,5
    djnz .add5Loop

.row0:
    ld a,e
    add hl,a
    ld a,(hl)
    ret

checkKey:
    in a,(ULA_CONTROL_PORT)
    ld e,0
    ld b,5
.loop:  
    bit 0, a
    jr z, .keyHit
    sra a
    djnz .loop
    ld a,0
    ret
.keyHit:
    dec b
    ld e,b
    ld a,1
    ret

;-----------------------------------------------------------------------------------
; 
; Function getMenuChar() -> uint8
;  
; Scans the keys 1,2 and 3. Allows delayed key repeats when the key is held down
; 
; Returns A = 1,2, 3 if pressed or 0 if not pressed
; 
;-----------------------------------------------------------------------------------
getMenuChar:

    ;Is key held down? Check if key was pressed last time
    ld a,KEYS_5_4_3_2_1
    in a,(ULA_CONTROL_PORT)
    ld b,a
    ld a,(repeatKey)
    cp b
    jr nz, .noRepeat

    ;Key is still held down, check if delay timer has elapsed
    ld ix,repeatTimer
    call Timing.hasTimerElapsed
    ld a,0
    ret z

.noRepeat:
    ;B = key scan bits
    ld a,b
    ;Store the key for next time so we can test key repeats
    ld (repeatKey),a
    ld b,1
    bit 0,a
    jr z, .pressed
    bit 1,a
    ld b,2
    jr z, .pressed
    bit 2,a
    ld b,3
    jr z, .pressed
    xor a

    ;Nothing pressed, stop the timer as will want to immediately process next key press
    call Timing.stopTimer
    ret

.pressed:
    ld ix,repeatTimer
    ld hl,KEY_REPEAT_DURATION
    call Timing.startTimer
    ld a,b
    ret


CHEAT_U equ 0
CHEAT_P equ 1
CHEAT_S equ 2 
CHEAT_C equ 3
CHEAT_U2 equ 4
CHEAT_M equ 5
CHEAT_B equ 6
CHEAT_A equ 7
CHEAT_G equ 8
CHEAT_ENTERED equ 9


;-----------------------------------------------------------------------------------
; 
; Function cheatCodeCheck() -> boolean
;  
; State machine to monitor if the cheatcode has been entered
; 
; Returns NZ - Cheat code entered
; 
;-----------------------------------------------------------------------------------
cheatCodeCheck
    ret

resetCheatCode:
    ret

;Cheat States
cheatStateTable:

cheatState db 0

    endmodule
