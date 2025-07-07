;-----------------------------------------------------------------------------------
; 
; Module Tilemap
; 
; A tilemap is a grid of 8x8 pixel blocks, the grid size is 
;   40x32 blocks  = 320x256px
;   80x32 blocks  = 640x256px
; 
; The grid covers the entire screen including the border.
; 
; Each tile pixel is 4-bit. A block is stored in the Tile Definitions
; allowing upto 256 definitions.
;
; The Tilemap Data specifies which tiles to display, each Tilemap data requires 2 bytes
; which includes palette offset (to access upto 256 colours), mirror/rotate flags and tile index.
; 
;-----------------------------------------------------------------------------------

    module Tilemap

START_OF_BANK_5		equ $4000
START_OF_TILEMAP	equ $6000	; after sys vars
START_OF_TILES		equ $6600	; Just after 40x32 tilemap

OFFSET_OF_MAP		equ (START_OF_TILEMAP - START_OF_BANK_5) >> 8
OFFSET_OF_TILES		equ (START_OF_TILES - START_OF_BANK_5) >> 8
PALETTE_TRANSPARENT_INDEX: equ $0f

;-----------------------------------------------------------------------------------
; 
; 
; 
; 
; 
;-----------------------------------------------------------------------------------
init:

    ;Index in the palette that defines the transparent colour
//    nextreg TILEMAP_TRANSPARENCY_INDEX,PALETTE_TRANSPARENT_INDEX
    nextreg TILEMAP_TRANSPARENCY_INDEX,0

    ; Bits
    ; 7:  1 to enable Tilemap
    ; 6:  1 for 80x32, 0 for 40x32
    ; 5:  1 to eliminate the attribute entry in the tilemap
    ; 4:  0 use first tilemap palette, 1 second
    ; 3:  1 to enable text mode (tile pixels are 1-bit, like UDG)
    ; 2:  Reserved 0
    ; 1:  1 512 tiles, 0 256 tiles
    ; 0:  1 to enfore tilemap over ULA priority
    ;
    ;Enable tilemap, 40x32, no attribute, 1st palette, 256 tiles, tilemap over ULA
	nextreg TILEMAP_CONTROL, %10100001


    ; Bits
    ; 7-4: Palette Offset
    ; 3: X Mirror
    ; 2: Y Mirror
    ; 1: Rotate
    ; 0: * 1 = ULA over tilemap, 0 = tilemap over ULA
	nextreg DEFAULT_TILEMAP_ATTRIBUTE, %00000000

	; Tell harware where to find tiles
	nextreg TILEMAP_BASE_ADDRESS, OFFSET_OF_MAP	; MSB of tilemap in bank 5
	nextreg TILEMAP_DEFINITIONS_BASE_ADDRESS, OFFSET_OF_TILES	; MSB of tilemap definitions

    ;
    ;Send palette to next hardware
    ;

	; Auto increment, select tilemap 1st palette
	nextreg PALETTE_ULA_CONTROL, %00110000
    ; Start with first entry
	nextreg PALETTE_INDEX, 0			

    ;Copy RRRGGGBB values
    ld b,16
    ld hl,palette
.nextColor:    
    ld a,(hl)
    inc hl
    nextreg PALETTE_VALUE, a
    djnz .nextColor
    ret

;-----------------------------------------------------------------------------------
; 
; 
; 
; 
;-----------------------------------------------------------------------------------
clear:
    ld bc, 40*32 - 1
    ld hl, START_OF_TILEMAP
    ld de,hl
    inc de
    ld (hl),0
    ldir
    ret

;-----------------------------------------------------------------------------------
; 
; 
; 
; 
;-----------------------------------------------------------------------------------
palette:
    db %00000000  ; Black
    db %11100000  ; Red
    db %00011100  ; Green
    db %00000011  ; Blue

    db %00000000  ; Black
    db %00000000  ; Black
    db %00000000  ; Black
    db %00000000  ; Black

    db %00000000  ; Black
    db %00000000  ; Black
    db %00000000  ; Black
    db %00000000  ; Black

    db %00000000  ; Black
    db %00000000  ; Black
    db %00000000  ; Black
    db $e3        ; Transparent

    endmodule
