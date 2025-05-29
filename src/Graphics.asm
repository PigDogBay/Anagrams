    module graphics


ULA_SCREEN:             equ 0x4000
ULA_SCREEN_SIZE:        equ 0x1800
ULA_COLOR_SCREEN:       equ 0x5800
ULA_COLOR_SCREEN_SIZE:  equ 0x0300




;-----------------------------------------------------------------------------------
; 
; Waits until raster hits line 192
; Dirty: BC, HL, A
;
;-----------------------------------------------------------------------------------
waitRaster:
    ; Raster returned in HL
    call readRaster
    ld a,192
    cp l
    jr nz, waitRaster


;-----------------------------------------------------------------------------------
; 
; Based on code by Patricia Curtis
; https://luckyredfish.com/patricias-z80-snippets/
; Dirty: BC, A
; Out: HL = current raster line on screen
;
;-----------------------------------------------------------------------------------
readRaster:
    ; Select and read video line MSB
    ld a,ACTIVE_VIDEO_LINE_MSB
    ld bc,TB_BLUE_REGISTER_SELECT
    out (c),a
    ; Point BC to TB_BLUE_REGISTER_ACCESS
    inc b
    in a,(c)
    ; Mask off unused bits
    and 1
    ld h,a

    ld a,ACTIVE_VIDEO_LINE_LSB
    ld bc,TB_BLUE_REGISTER_SELECT
    out (c),a
    ; Point BC to TB_BLUE_REGISTER_ACCESS
    inc b
    in a,(c)
    ld l,a
    ret

;-----------------------------------------------------------------------------------
; 
; Fills ULA  attributes with specified color
; In D: Attribute paper/ink colours
;-----------------------------------------------------------------------------------
setAttributes:
    ld bc,ULA_COLOR_SCREEN_SIZE - 1
    ld hl,ULA_COLOR_SCREEN
    ; Set first byte to the colour
    ld (hl),d
    ; Point DE to next attibute
    ld e,l
    ld d,h
    inc de
    ;Fill rest of attributes
    ldir
    ret

;-----------------------------------------------------------------------------------
; 
; Disable interrupts before calling this function
; Clear the Layer 2 screen (256x192) with the specified colour in D register
; In: D colour
;-----------------------------------------------------------------------------------
clearLayer2:
    push bc
    push de
    push hl

    ld bc, L2_ACCESS_PORT 
    in a, (c)				; get the current bank
    push af 				; store it 
    xor a 
    out	(c),a 
    
    ld d,a					; byte to clear to
    ld e,3					; number of blocks
    ld a,1					; first bank... (bank 0 with write enable bit set)

    ld bc, L2_ACCESS_PORT           
.loadAll:	
    out	(c),a				; bank in first bank
    push af       
            ; Fill lower 16K with the desired byte
    ld hl,0
.clearLoop:		
    ld (hl),d
    inc l
    jr nz, .clearLoop

    inc h
    ld a,h
    cp $40
    jr nz, .clearLoop

    pop af					; get block back
    add a,$40
    dec e					; loops 3 times
    jr nz, .loadAll

    ld bc, L2_ACCESS_PORT			; switch off background (should probably do an IN to get the original value)

    pop af 
    out	(c),a     

    pop	hl
    pop de
    pop bc	

    ret

    endmodule