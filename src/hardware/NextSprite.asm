    module NextSprite


;-----------------------------------------------------------------------------------
;
; Function: load(uint8 bank) -> bool
;
; Load sprite data from the 8k banks: bank and bank + 1
;
; Disable interrupts before calling this function
;
; In:
;       A First bank containing the sprite data, next bank is A+1 
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
load:
    push hl
    push bc

    ; swap out ROM with bank, bank+1
    nextreg MMU_0,a 
    inc a 
    nextreg MMU_1,a

    ; Set first sprite pattern slot to 0
    xor a
    ld bc, SPRITE_STATUS_SLOT_SELECT
    out (c), a

    ;Upload the DMA program
    ld hl, .dmaProgram
    ld b, .dmaProgramLength
    ld c, DMA_PORT
    otir

    ; Restore ROM
    nextreg MMU_0, $FF
    nextreg MMU_1, $FF
    
    pop bc
    pop hl
    ret
;See page p49 of the ZX Next Assembly Developer for details on WR bits
; ' apostrophes are used to split up the bit fields for readability, sjasm will strip'em out
.dmaProgram:
	DB %1'00000'11		    ; WR6 - Disable DMA
	DB %0'11'11'1'01		; WR0 - append length + port A address, A->B
	DW $0000		        ; WR0 par 1&2 - port A start address (MMU_0 start address is 0x0000)
	DW 64 * 256			    ; WR0 par 3&4 - transfer length (64 sprites  x 256 bytes per sprite)
	DB %0'0'01'01'00		; WR1 - A incr., A=memory
	DB %0'0'10'1'000		; WR2 - B fixed, B=I/O
	DB %1'01'0'11'01		; WR4 - continuous, append port B address
    ; WR4 par 1&2 - port B address
	DW SPRITE_PATTERN_UPLOAD_256		    
	DB %10'0'0'0010         ; WR5 - stop on end of block, CE only
	DB %1'10011'11		    ; WR6 - load addresses into DMA counters
	DB %1'00001'11		    ; WR6 - enable DMA
.dmaProgramLength = $ - .dmaProgram


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
    ;ensure bit 0 is clear
    res 0,d
    ;A bit 0 has X MSB, so or with D
    or d
    out (c),a

    ; Byte 4
    ; Bit 7 - Visibility
    ; Bit 6 - 0, don't need 5th byte for scaling
    ; Bit 5-0 - Pattern index
    inc hl
    ld a,(hl)
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
