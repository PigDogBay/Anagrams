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
    
    ;Reset offsets
    nextreg LAYER_2_X_OFFSET,0
    nextreg LAYER_2_X_OFFSET_MSB,0
    nextreg LAYER_2_Y_OFFSET,0

    nextreg ULA_X_OFFSET,0
    nextreg ULA_Y_OFFSET,0

    nextreg TILEMAP_OFFSET_X_MSB,0
    nextreg TILEMAP_OFFSET_X_LSB,0
    nextreg TILEMAP_OFFSET_Y,0

    ret

;-----------------------------------------------------------------------------------
; 
; Waits until raster hits line 224 which is just below the 320x256 display
; Note line line 0 of the raster is at y=32 for the 320x256 display, so 
; 256 - 32 = 224 
;
; Dirty: BC, HL, A
;
;-----------------------------------------------------------------------------------
waitRaster:
    ; Raster returned in HL
    call readRaster
    ld a,224
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
;
; Bits:  
;   7:   1 enable flashing
;   6:   1 to enable bright
; 5-3:   Paper
; 2-0:   Ink
;     000 - Black
;     001 - Blue
;     010 - Red
;     011 - Magenta
;     100 - Green
;     101 - Cyan
;     110 - Yellow
;     111 - White
; 
;-----------------------------------------------------------------------------------
setAttributes:
    ld bc,ULA_COLOR_SCREEN_SIZE - 1
    ld hl,ULA_COLOR_SCREEN
    ; Set first byte to the colour
    ld (hl),d
    ; Point DE to next attibute
    ld de,hl
    inc de
    ;Fill rest of attributes
    ldir
    ret

;-----------------------------------------------------------------------------------
; 
; Function: setPixels(uint8 pixelFillValue)
;
; Fills the entire ULA screen pixels with the specified value
;  
; In: Pixel value to fill each pixel with
; 
; Dirty BC, DE, HL
;-----------------------------------------------------------------------------------
setPixels:
    ld bc,ULA_SCREEN_SIZE - 1
    ld hl,ULA_SCREEN
    ; Set first byte to the colour
    ld (hl),d
    ; Point DE to next attibute
    ld de,hl
    inc de
    ;Fill rest of attributes
    ldir
    ret



;-----------------------------------------------------------------------------------
; 
; Function: loadLayer2_9BitPalette(uint16 ptr, uint8 count)
; 
; Loads the 9 bit colours to the Layer 2 first palette
; Colours are a arranged in order of index, 0 to count-1 (255 max)
; Each colour is 2 bytes, RRRGGGBB, 0000000B (the second byte contains the blue LSBit)
; 
; In: HL - pointer to start of colour values
;      B - number of colours to add
; 
; Dirty: A,HL,B
; 
;-----------------------------------------------------------------------------------
loadLayer2_9BitPalette:

    ; Bit 7: 0 Auto increment
    ; 6-4: 001 Layer 2 first palette
    ; 3-1: First palettes active for Sprites, L2, ULA
    ; 0: Disable ULANext
    nextreg PALETTE_ULA_CONTROL,%00010000
    nextreg PALETTE_INDEX,0
.next
    ;Wite out 9bit colour value RRRGGGBBB
    ; Write RRRGGGBB
    ld a,(hl)
    inc hl
    nextreg PALETTE_ULA_PALETTE_EXTENSION,a
    ; Write 0000000B - low bit of blue
    ld a,(hl)
    inc hl
    nextreg PALETTE_ULA_PALETTE_EXTENSION,a
    djnz .next

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

    ;DMA.fill8kBank params
    ld h, LAYER2_START_8K_BANK
    ;DMA.fill8kBank, takes fill value in L
    ld l,a

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

    ; 7-6 Reserved
    ; 5-4 Layer 2 Resolution
    ;    00 - 256x192 256 colours 
    ;    01 - 320x256 256 colours 
    ;    10 - 640x256  16 colours 
    ; 3-0 Palette offset
    nextreg LAYER_2_CONTROL, %00010000

    ;Set the 16k bank number where layer 2 video memory begins
    nextreg LAYER_2_RAM_PAGE, LAYER2_START_16K_BANK

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


;-----------------------------------------------------------------------------------
; 
; To create Layer 2 images, 320x256 256 colours
; 
; To create images: 
; 
; 1. Images need to be first resized to 320x256 by resizing and cropping, this can be done in Preview
;
; 2 . Convert the image to an uncompressed indexed bitmap with 256 colour palette, 8 bit pixels, 
; BMP3 - widely supported bitmap format
; 
; convert oxford-small.jpg -colors 256 -depth 8 -compress none BMP3:oxford.bmp
;
; 3. Use gfx2next (See https://www.rustypixels.uk/gfx2next/): 
; -bitmap Output Next bitmap .nxi
; -bitmap-y Set up the memory layout (y-x order) for 320x256
; -bank-8k Split the file into 8k chunks so that it can be easily loaded into 8k banks
; -pal-std Convert to the Spectrum Next standard palette colours
; (See https://www.rustypixels.uk/gfx2next/)
; 
; ~/work/Next/tools/Gfx2Next/build/gfx2next -bitmap -bitmap-y -pal-std -bank-8k oxford.bmp
; 
; 
; 
;-----------------------------------------------------------------------------------
titleScreen:
    ; Load palette for Title screen, residing at 8k bank 50 0x0000 - 0x00ff
    nextreg MMU_0, 50
    ld hl,0
    ld b,255
    call Graphics.loadLayer2_9BitPalette
    ; Restore ROM
    nextreg MMU_0, $FF

    ; 7-6 Reserved
    ; 5-4 Layer 2 Resolution
    ;    00 - 256x192 256 colours 
    ;    01 - 320x256 256 colours 
    ;    10 - 640x256  16 colours 
    ; 3-0 Palette offset
    nextreg LAYER_2_CONTROL, %00010000

    ; 16k Bank, first 8k bank of image is at 40
    ; So 16k bank is 40/2 = 20
    nextreg LAYER_2_RAM_PAGE, 20
    ret


;-----------------------------------------------------------------------------------
; 
; Function: loadULAPalette()
; 
; Restores the classic ULA colors
; 
; Dirty: A,B, HL 
; 
;-----------------------------------------------------------------------------------
loadULAPalette:
    ; Auto increment, select ULA 1st palette
	nextreg PALETTE_ULA_CONTROL, %00000000
    ; Start with first entry
	nextreg PALETTE_INDEX, 0			

    ;Copy RRRGGGBB values
    ld b,32
    ld hl,ulaPalette
.nextColor:    
    ld a,(hl)
    inc hl
    nextreg PALETTE_VALUE, a
    djnz .nextColor
    ret


; Default Classic ULA colors
ulaPalette:
    ; Ink
    db 0    ; Black
    db 2    ; Blue 
    db 160  ; Red
    db 162  ; Magenta
    db 20   ; Green
    db 22   ; Cyan
    db 180  ; Yellow
    db 182  ; White
    db 0    ; Black
    db 3    ; Bright blue
    db 224  ; Bright red
    db 231  ; Bright magenta
    db 28   ; Bright green
    db 31   ; Bright cyan
    db 252  ; Bright yellow
    db 255  ; Bright white

    ; Paper and Border
    db 0    ; Black
    db 2    ; Blue 
    db 160  ; Red
    db 162  ; Magenta
    db 20   ; Green
    db 22   ; Cyan
    db 180  ; Yellow
    db 182  ; White
    db 0    ; Black
    db 3    ; Bright blue
    db 224  ; Bright red
    db 231  ; Bright magenta
    db 28   ; Bright green
    db 31   ; Bright cyan
    db 252  ; Bright yellow
    db 255  ; Bright white

    endmodule