    module Graphics


ULA_SCREEN:             equ 0x4000
ULA_SCREEN_SIZE:        equ 0x1800
ULA_COLOR_SCREEN:       equ 0x5800
ULA_COLOR_SCREEN_SIZE:  equ 0x0300

LAYER2_START_16K_BANK:  equ 9
LAYER2_START_8K_BANK:   equ LAYER2_START_16K_BANK * 2

LAYER2_RESOLUTION_X:   equ 320
LAYER2_RESOLUTION_Y:   equ 256
LAYER2_NUM_BANKS:      equ LAYER2_RESOLUTION_X * LAYER2_RESOLUTION_Y / BANK_8K_SIZE
LAYER2_BANK_MAX_X:     equ BANK_8K_SIZE / LAYER2_RESOLUTION_Y




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
        call Graphics.setAttributes
    endm




;-----------------------------------------------------------------------------------
; 
; Function: resetAllClipWindows() 
; 
; Resets the clip windows so that the entire screen is visible for
; ULA, Tilemap, Sprites and Layer 2 display devices
; 
;-----------------------------------------------------------------------------------
resetAllClipWindows:
    ;Reset clip window index registers
    ; 7-4 reserved
    ; 3: 1 to reset Tilemap clip-window register index
    ; 2: 1 to reset ULA clip-window register index
    ; 1: 1 to reset Sprite clip-window register index
    ; 0: 1 to reset Layer 2 clip-window register index
    nextreg CLIP_WINDOW_CONTROL, %00001111

    ;Send 0,255,0,255 (x1,x2,y1,y2) to each clip window register
    nextreg CLIP_WINDOW_LAYER_2,0
    nextreg CLIP_WINDOW_LAYER_2,255
    nextreg CLIP_WINDOW_LAYER_2,0
    nextreg CLIP_WINDOW_LAYER_2,255
    
    nextreg CLIP_WINDOW_SPRITES,0
    nextreg CLIP_WINDOW_SPRITES,255
    nextreg CLIP_WINDOW_SPRITES,0
    nextreg CLIP_WINDOW_SPRITES,255
    
    nextreg CLIP_WINDOW_ULA,0
    nextreg CLIP_WINDOW_ULA,255
    nextreg CLIP_WINDOW_ULA,0
    nextreg CLIP_WINDOW_ULA,255
    
    nextreg CLIP_WINDOW_TILEMAP,0
    nextreg CLIP_WINDOW_TILEMAP,255
    nextreg CLIP_WINDOW_TILEMAP,0
    nextreg CLIP_WINDOW_TILEMAP,255
    
    ret

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
; Function fillLayer2_320(uint8 fillColour)
; 
; Disable interrupts before calling this function as it swaps out the ROM banks
; Fill the Layer 2 screen (320x256) with the specified colour
;
; In: A colour
; Dirty: A 
;
;-----------------------------------------------------------------------------------
fillLayer2_320:
    push bc
    push hl
    ld h, LAYER2_START_8K_BANK
    ld l,a
    ld b,LAYER2_NUM_BANKS
.nextBank:
    call DMA.fill8kBank
    inc h
    djnz .nextBank
    pop hl
    pop bc
    ret




;-----------------------------------------------------------------------------------
; 
; Function: layer2Test()
; 
; Example code from ZX Spectrum Next Assembly Developer Guide
; 
; Fills layer 2 256x196 (256 colours) with coloured (0-255) vertical bars
; The clever bit here is the Y value in D, that combines the Layer 2 Bank offset + Y co-ord
; and then converts that to an address in memory.
;
; The demonstrates how to enable layer 2 and set up it's memory banks
;
;
; Dirty: AF, BC, DE
;-----------------------------------------------------------------------------------
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
    nextreg LAYER_2_RAM_PAGE, LAYER2_START_16K_BANK

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
    add a, LAYER2_START_8K_BANK
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
; Function: layer2Test320()
; 
; Example code from ZX Spectrum Next Assembly Developer Guide (Ch3 p77)
; 
; Fills layer 2 320x256 (256 colours) with coloured (0-255) vertical bars
;
;
;
;
;
;
; Dirty: AF, BC, DE
;-----------------------------------------------------------------------------------
layer2Test320:

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
    nextreg LAYER_2_RAM_PAGE, LAYER2_START_16K_BANK

    ; 7-6 Reserved
    ; 5-4 Layer 2 Resolution
    ;    00 - 256x192 256 colours 
    ;    01 - 320x256 256 colours 
    ;    10 - 640x256  16 colours 
    ; 3-0 Palette offset
    nextreg LAYER_2_CONTROL, %00010000


    ld b, LAYER2_START_8K_BANK
    ; Colour index
    ld h, 0
.nextBank:
    ld a,b
    nextreg MMU_6,a
    ;MMU_6 start address
    ld de,$c000
.nextY:
    ;write color index, straight line down
    ld a,h
    ld (de),a
    ;inc Y
    inc e
    jr nz, .nextY

    ;next x value (0-31) for this current bank
    inc d
    ;next color
    inc h
    ld a,d
    ;Strip off $c000 to get x-coord
    and %00111111
    cp LAYER2_BANK_MAX_X
    jr nz, .nextY

    ;next bank
    inc b
    ld a,b
    cp LAYER2_START_8K_BANK+LAYER2_NUM_BANKS
    jr nz, .nextBank

    ret

 
    endmodule