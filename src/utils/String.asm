;-----------------------------------------------------------------------------------
;
; Module: String
;
; Strings are null terminated, each character is a single byte
;
; Functions: 
;    len(uint16 ptr) -> uint8
; 
;-----------------------------------------------------------------------------------

    module String


;-----------------------------------------------------------------------------------
;
; Function: len(uint16 ptr) -> uint8
;
; Calculates the length of a String upto 253 bytes, the length excludes 0 terminator
; 
; In:  HL pointer to the string
; Out: A length
;      A = 255 string is longer than 255 bytes
;
; Dirty: A
;-----------------------------------------------------------------------------------

len:
    push hl
    push bc
    ld a,0
    ; Search for a max length of 255 chars
    ld bc,0x00ff
    cpir

    or c
    ld a,255
    jr z, .terminatorNotFound


    ; len = 255 - 1 - remaining count
    ; -1 for the \0 terminator
    ld a,254
    sub c

.terminatorNotFound:
    pop bc
    pop hl

    ret


    endmodule