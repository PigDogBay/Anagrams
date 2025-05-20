    MODULE sprite

; Sprite attributes data struct
id:          equ 0
x:           equ 1
y:           equ 3
pattern:     equ 4
size:        equ 5

; Disable interrupts before calling this function
; Load 2 memory consequetive 8k banks into sprite memory
; Parameters:
; bank = First bank, next bank is bank+1 (Set in A register)
load:
    ; swap out ROM with bank, bank+1
    nextreg MMU_0,a 
    inc a 
    nextreg MMU_1,a

    ; Set first sprite pattern slot to 0
    xor a
    ld bc, SPRITE_STATUS_SLOT_SELECT
    out (c), a

    ; Sprite data starts at 0x0000
    ld hl,0
    ; Copy 64 sprite patterns to sprite memory
    ld a,64
next_pattern:
        ; b is set to 0 (256 bytes), c is set to the pattern upload port address
        ld bc, SPRITE_PATTERN_UPLOAD_256
        ; Send data to sprite memory port, HL and sprite pattern will automatically increment
        otir
        dec a
        jr nz, next_pattern

    ; Restore ROM
    nextreg $50, $FF
    nextreg $51, $FF
    ret

; HL = pointer to sprite data structure
update:
    ; Set sprite id for attribute upload
    ld bc, SPRITE_STATUS_SLOT_SELECT
    ld a,(hl)
    out (c), a

    ld bc, SPRITE_ATTRIBUTE_UPLOAD

    ; Byte 1
    ; X position (Low 8 bits)
    inc hl
    ld a,(hl)
    out (c),a

    ; X position bit 9
    inc hl
    ld a,(hl)
    and 1

    ; Byte 2
    ; Y position (Low 8 bits)
    inc hl
    ld d,(hl)
    out (c),d

    ; Byte 3
    ; Bit 0 - MSB of X position
    out (c),a

    ; Byte 4
    ; Bit 7 - Visibility
    ; Bit 6 - 0, don't need 5th byte for scaling
    ; Bit 5-0 - Pattern index
    inc hl
    ld a,(hl)
    ; enable visibility bit 7
    or $80
    out (c),a
    ; Byte 5, not used here
    ret


    endmodule
