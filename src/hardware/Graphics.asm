    module graphics


ULA_SCREEN:             equ 0x4000
ULA_SCREEN_SIZE:        equ 0x1800
ULA_COLOR_SCREEN:       equ 0x5800
ULA_COLOR_SCREEN_SIZE:  equ 0x0300

;-----------------------------------------------------------------------------------
; 
; Function: layer2Test()
; 
; Example code from ZX Spectrum Next Assembly Developer Guide
; 
; Fills layer 2 256x196 with coloured (0-255) vertical bars
; The clever bit here is the Y value in D, that combines the Layer 2 Bank offset + Y co-ord
; and then converts that to an address in memory.
;
; The demonstrates how to enable layer 2 and set up it's memory banks
;
;
; Dirty: AF, BC, DE
;-----------------------------------------------------------------------------------
START_16K_BANK: equ 9
START_8K_BANK: equ START_16K_BANK * 2
layer2Test:
    ; Enable layer 2
    ld bc, L2_ACCESS_PORT
    ; Bits
    ; 7-6 = 00 Bank select, first 16k
    ; 3 = 0 Layer 2 ram page register
    ; 2 = 0 Read disabled
    ; 1 = 1 Layer 2 visible
    ; 2 = 0 Write disabled
    ld a, %00000010
    out (c),a

    ;Set the 16k bank number where layer 2 video memory begins
    nextreg LAYER_2_RAM_PAGE, START_16K_BANK

    ; D = y, start at the top of the screen
    ; Each 8k bank represents 32 lines, Y co-ord needs 5 bits
    ; Addressing Bits (0 - 191): 
    ; 7-5: Bank offset (0 to 5)
    ; 0-4: Y co-ord into the bank (0-31)
    ld d,0

.nextY:
    ld a,d
    and %11100000   ;32100000
    rlca            ;21000003
    rlca            ;10000032
    rlca            ;00000321
    add a, START_8K_BANK
    nextreg MMU_6,a

    push de
    ; ld A with Bank + Y
    ld a,d
    ; Strip off bank
    and %00011111
    ; MMU_6 starts at $C000
    ; Pixel memory address = $C000 + Y*256 + X
    ; OR with $C0 (192 %1100 0000)
    or $c0
    ld d,a
    ld e,0

.nextX:
    ld a,e
    ld (de),a
    inc e
    jr nz, .nextX

    pop de
    inc d
    ld a,d
    ; Check bank offset, when = 6 finished (192 = %110 00000)
    cp 192
    jr c, .nextY
    ret


;-----------------------------------------------------------------------------------
; 
;   Macro to set the border colour
;
;   Dirty: A
;
;-----------------------------------------------------------------------------------
    macro BORDER col
        ld a, col
        out ULA_CONTROL_PORT,a
    endm
 
;-----------------------------------------------------------------------------------
; 
;   Macro to set the border colour
;
;   Dirty: BC,DE,HL,A
;
;-----------------------------------------------------------------------------------
    macro CLS
        ld d,0
        call graphics.setAttributes
    endm
 

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
; Clear the Layer 2 screen (256x192) with the specified colour
;
; In: A colour
; Dirty: BC,DE,HL 
;
;-----------------------------------------------------------------------------------
clearLayer2:
    ; Store colour in D
    ld d,a
    ld bc, L2_ACCESS_PORT 
    in a, (c)				; get the current bank
    push af 				; store it 
    xor a 
    out	(c),a 
    
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

    ret

    endmodule