    module NextSprite


;-----------------------------------------------------------------------------------
;
; Load sprite data from banks
;
; Disable interrupts before calling this function
; Load 2 memory consequetive 8k banks into sprite memory
; Parameters:
; bank = First bank, next bank is bank+1 (Set in A register)
;
;-----------------------------------------------------------------------------------
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

;-----------------------------------------------------------------------------------
; 
; Update sprite
;
; in HL = pointer to spriteItem data structure
; out HL = next sprite in the list
; dirty a,d
;
;-----------------------------------------------------------------------------------
update:
    ;preserve bc
    push bc
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
    ;	4-7		Palette offset, added to each palette index from pattern before drawing
    ;	3		Enable X mirror
    ;	2		Enable Y mirror
    ;	1		Enable rotation    
    ;   0       MSB of X position
    inc hl
    ld d,(hl)
    ;A bit 0 has X MSB, so or with D
    or d
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
    ;Skip gameId and flags, point to the next sprite in the list
    inc hl
    inc hl
    inc hl
    
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Remove sprite
; Sets all attributes to zero and sprite invisibile
; In: A = Sprite ID
; 
;-----------------------------------------------------------------------------------
remove:
    ;preserve bc
    push bc
    ; Set sprite id for attribute upload
    ld bc, SPRITE_STATUS_SLOT_SELECT
    out (c), a

    ld bc, SPRITE_ATTRIBUTE_UPLOAD

    ; Byte 1
    ; X position (Low 8 bits)
    xor a
    out (c),a

    ; Byte 2
    ; Y position (Low 8 bits)
    out (c),a

    ; Byte 3
    ; Bit 0 - MSB of X position
    out (c),a

    ; Byte 4
    ; Bit 7 - 0 Invisible
    ; Bit 6 - 0 No 5th byte for scaling
    ; Bit 5 - 0 Pattern index
    out (c),a
    ; Byte 5, not used here

    ; Recover BC
    pop bc
    ret

;-----------------------------------------------------------------------------------
; 
; Remove all sprites
;
;-----------------------------------------------------------------------------------
removeAll:
    ld b,127
.loop:
    ; Remove sprites 1-127
    ld a,b
    call remove
    djnz .loop
    ; Remove 0 sprite
    xor a
    call remove
    ret

    endmodule
