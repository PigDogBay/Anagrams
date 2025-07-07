; Spectrum ROM routines
ROM_CLS:                equ $0daf
ROM_OPEN_CHANNEL:       equ $1601
ROM_PRINT:              equ $203c


;  Ports and registers
;  See https://www.specnext.com/tbblue-io-port-system/'



;  (R/W) 0x07 (07) => Turbo mode:
;  bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz)
;  (00 after a PoR or Hard-reset)
CPU_SPEED:                       equ $07

; Sets the layer 2 start 16k bank, for 256x192 requires 3x16k, 320x256 5x16k
LAYER_2_RAM_PAGE:                       equ $12
LAYER_2_RAM_SHADOW_PAGE:                equ $13

;$E3 is the default value for the ULA transparency colour
;Set to $E7 for Bright Magenta (paper 3)
GLOBAL_TRANSPARENCY:                 equ $14

LAYER_2_X_OFFSET:                       equ $16
LAYER_2_Y_OFFSET:                       equ $17

;First reset the index to 0 via CLIP_WINDOW_CONTROL
;Then write 4 bytes: X1,X2,Y1,Y2 
;Note that for 320,640 modes, X values are double/quadrupled
;To set clip for whole window
;  
; BYTE    256x192    320x256    640x256
;  X1        0          0          0
;  X2        255        159 (x2)   159 (x4)
;  Y1        0          0          0
;  Y2        191        255        255
;
; Note to be sure, you can set 0,255,0,255 to ensure entire screen is visible
;
;Below are the registers for each display device
CLIP_WINDOW_LAYER_2:                    equ $18
CLIP_WINDOW_SPRITES:                    equ $19
CLIP_WINDOW_ULA:                        equ $1A
; X1, X2, Y1, Y2 
CLIP_WINDOW_TILEMAP:                    equ $1B
;Bits
; 7-4 reserved
; 3: 1 to reset Tilemap clip-window register
; 2: 1 to reset ULA clip-window register
; 1: 1 to reset Sprite clip-window register
; 0: 1 to reset Layer 2 clip-window register
CLIP_WINDOW_CONTROL:                    equ $1C

;(R/W) 0x15 (21) => Sprite and Layers system
;bit 7 = LoRes mode, 128 x 96 x 256 colours (1 = enabled)
;bit 6 = Sprite priority (1 = sprite 0 on top, 0 = sprite 127 on top)
;bit 5 = Enable sprite clipping in over border mode (1 = enabled)
;bits 4-2 = set layers priorities:
;Reset default is 000, sprites over the Layer 2, over the ULA graphics
;000 - S L U
;001 - L S U
;010 - S U L
;011 - L U S
;100 - U S L
;101 - U L S
;110 - S(U+L) ULA and Layer 2 combined, colours clamped to 7
;111 - S(U+L-5) ULA and Layer 2 combined, colours clamped to [0,7]
;bit 1 = Over border (1 = yes)(Back to 0 after a reset)
;bit 0 = Sprites visible (1 = visible)(Back to 0 after a reset)
SPRITE_LAYERS_SYSTEM:                  equ $15

;(W) 0x1C (28) => Clip Window control
;bit 3 - reset the tilemap clip index
;bit 2 - reset the ULA/LoRes clip index.
;bit 1 - reset the sprite clip index.
;bit 0 - reset the Layer 2 clip index.
;Set to $0f to reset all clip indexes.
NR_CLIP_WINDOW_CONTROL:                equ $1C

ACTIVE_VIDEO_LINE_MSB:                 equ $1E
ACTIVE_VIDEO_LINE_LSB:                 equ $1F

; Tilemap offset in pixel
;
; X: 0-319 for 40x32, 0-639 for 80x32
; Y: 0-255
;
; Bits 0-1
TILEMAP_OFFSET_X_MSB:                  equ $2F
; Bits 0-7
TILEMAP_OFFSET_X_LSB:                  equ $30
; Bits 0-7
TILEMAP_OFFSET_Y:                      equ $31


PALETTE_INDEX:                         equ $40
PALETTE_VALUE:                         equ $41
PALETTE_ULA_INK_COLOR_MASK:            equ $42

; Bits:
; 7: 0 to enable auto-increment
; 6-4 Select palette:
;   000 ULA first palette
;   100 ULA second palette
;   001 Layer 2 first palette
;   101 Layer 2 second palette
;   010 Sprites first palette
;   110 Sprites second palette
;   011 Tilemap first palette
;   111 Tilemap second palette
; 3: Selects active Sprites palette (0 = first, 1 = second)
; 2: Selects active Layer 2 palette (0 = first, 1 = second)
; 1: Selects active ULA palette (0 = first, 1 = second)
; 0: Enables ULANext mode if 1 
PALETTE_ULA_CONTROL:                   equ $43

; Reads or writes 9-bit color definition
; Byte 1: RRR GGG BB
; Byte 2: P 000000 B 
;     Bit 7: Layer 2 Priority, if 1 colour will always appear on top of every other layer
;     Bit 0: low bit of blue color
PALETTE_ULA_PALETTE_EXTENSION:         equ $44

; Colour to be used when all layers contain transparent pixels
; RRRGGGBB
; Default 0 (black)
TRANSPARENCY_COLOUR_FALLBACK:          equ $4A

; Index into the sprite palette, default is $E3
; https://wiki.specnext.dev/Sprites_Transparency_Index_Register
SPRITES_TRANSPARENCY_INDEX:            equ $4B

; Bits:
; 7-4 Reserved
; 4-0 Index of transparent colour in the tilemap palette
;
; Note: The pixel index is compared before the palette offset is applied
; so only need to specify the transparency colour once in the palette: 0-15
; Default is 15
TILEMAP_TRANSPARENCY_INDEX:            equ $4C


MMU_0:                                 equ $50          ; Slot $0000 - $1FFF (0     - 8191)
MMU_1:                                 equ $51          ; Slot $2000 - $3FFF (8192  - 16383)
MMU_2:                                 equ $52          ; Slot $4000 - $5FFF (16384 - 24575)
MMU_3:                                 equ $53          ; Slot $6000 - $7FFF (24576 - 32767)
MMU_4:                                 equ $54          ; Slot $8000 - $9FFF (32768 - 40959)
MMU_5:                                 equ $55          ; Slot $A000 - $BFFF (40960 - 49151)
MMU_6:                                 equ $56          ; Slot $C000 - $DFFF (49152 - 57343)
MMU_7:                                 equ $57          ; Slot $E000 - $FFFF (57355 - 65535)

;Byte 1 is the low eight bits of the X position. The MSB is in byte 3 (anchor sprite only).
;Byte 2 is the low eight bits of the Y position. The MSB is in optional byte 5 (anchor sprite only).
;
;Byte 3 is bitmapped:
;	4-7		Palette offset, added to each palette index from pattern before drawing
;	3		Enable X mirror
;	2		Enable Y mirror
;	1		Enable rotation
;	0		Anchor (normal) sprite: MSB of X coordinate

;Byte 4 is bitmapped:
;	7	Enable visibility
;	6	If 1, the optional 5th attribute byte should follow fourth one.
;		If 0, only four attribute bytes are expected (accidental fifth byte send to port will be treated as first byte of next sprite attributes), and all extra sprite features (not covered by 4 byte block) will be reset to zero (as if 5th byte equal to value zero was explicitly sent).
;	5-0	Pattern index ("Name")
;relative sprite: enable relative Palette offset (1 = the anchor Palette offset is added, 0 = independent Palette offset)
;
;Optional (when bit 6 is set in byte 4) byte 5 is bitmapped:
;For anchor sprites:
;	7-6	"H N6" - "H" is 4/8 bit graphics selector, "N6" is sub-pattern selector for 4 bit modes.
;		%00 = 8-bit colour patterns (256 bytes), this sprite is "anchor"
;		%01 = this sprite is "relative" (4/8-bit colour is selected by "anchor" sprite) → see tables below
;		%10 = 4-bit colour pattern (128 bytes) using bytes 0..127 of pattern slot, this sprite is "anchor"
;		%11 = 4-bit colour pattern (128 bytes) using bytes 128..255 of pattern slot, this sprite is "anchor	"
;	5	Type for following relative sprites: 0 = "composite", 1 = "big sprite"
;	4-3	x-axis scale factor: %00 = 1x (16 pixels), %01 = 2x, %10 = 4x, %11 = 8x (128 pixels)
;	2-1	y-axis scale factor: %00 = 1x (16 pixels), %01 = 2x, %10 = 4x, %11 = 8x (128 pixels)
;	0	MSB of Y coordinate
;see https://wiki.specnext.dev/Sprite_Attribute_Upload
SPRITE_ATTRIBUTE_UPLOAD:               equ $57

;see https://wiki.specnext.dev/Sprite_Pattern_Upload
SPRITE_PATTERN_UPLOAD_256:             equ $005B


; Bits
;   7: 1 to disable ULA (default 0)
; 6-5: Blending in SLU modes 6 and 7
;    00 - ULA as blended colour
;    01 - No blending
;    10 - ULA/tilemap as blend colour
;    11 - Tilemap as blend colour
;  4: Cancel entries in 8x5 matrix for extended keys
;  3: 1 to enable ULA+
;  2: 1 to enable ULA half pixel scroll
;  1: 0 Reserved  
;  0: 1 to enable stencil mode when ULA and tilemap are enabled
ULA_CONTROL:                           equ $68


;https://wiki.specnext.dev/Display_Control_1_Register
DISPLAY_CONTROL_1:                     equ $69

; Bits
; 7:  1 to enable Tilemap
; 6:  1 for 80x32, 0 for 40x32
; 5:  1 to eliminate the attribute entry in the tilemap
; 4:  0 use first tilemap palette, 1 second
; 3:  1 to enable text mode (tile pixels are 1-bit, like UDG)
; 2:  Reserved 0
; 1:  1 512 tiles, 0 256 tiles
; 0:  1 to enfore tilemap over ULA priority
TILEMAP_CONTROL:                       equ $6B

; This attribute is used if bit 5 of TILEMAP_CONTROL is set
;
; Bits
; 7-4: Palette Offset
; 3: X Mirror
; 2: Y Mirror
; 1: Rotate
; 0: * 1 = ULA over tilemap, 0 = tilemap over ULA
;
; * If bit 1 of TILEMAP_CONTROL is set, used as ninth bit of tile ID (allowing 512 tiles)
;   ULA over tilemap is default
;
;** If bit 3 of TILEMAP_CONTROL is set (text-mode), bits 7-1 are palette offset
DEFAULT_TILEMAP_ATTRIBUTE:             equ $6C

;
; Bits
;   7:  1 to select 8k bank 7, 0 for 16k bank 5
;   6:  Reserved 0
; 5-0: Page in the tilemap bank, Address = slot_address +  Page * 256
;      default $2C (Address $6C00)
;    0x4000-0x7f00 in bank 5
;    0xc000-0xff00 in bank 7
TILEMAP_BASE_ADDRESS:                  equ $6E
;
; Bits
;   7:  1 to select 8k bank 7, 0 for 16k bank 5
;   6:  Reserved 0
; 5-0: Page in the tilemap bank, Address = slot_address +  Page * 256
;      default $2C (Address $6C00)
;    0x4000-0x7f00 in bank 5
;    0xc000-0xff00 in bank 7
TILEMAP_DEFINITIONS_BASE_ADDRESS:      equ $6F


;Bits
; 7-6 Reserved
; 5-4 Layer 2 Resolution
;    00 - 256x192 256 colours 
;    01 - 320x256 256 colours 
;    10 - 640x256  16 colours 
; 3-0 Palette offset
LAYER_2_CONTROL:                       equ $70

;Bits
; 7-1 Reserved, must be 0
; 0 MSB for X pixel offset
LAYER_2_X_OFFSET_MSB:                  equ $71




;
; Ports
;


;$xx6B where xx is program length
DMA_PORT:                              equ $6B


;Bits
; 7-5 Unused
; 4 EAR output (speaker) or Input from tape/PI
; 3 MIC output (saving via audio jack)
; 2-0 Border colour
ULA_CONTROL_PORT:                      equ $FE

;See https://wiki.specnext.dev/Layer_2_Access_Port
;
; Enables Layer 2 and controls paging of layer 2 screen into lower memory.
; Bits:
;       7-6 Video RAM bank select (read/write paging)
;       5 - 0 reserved    
;       4 - 0
;       3 - 0 LAYER_2_RAM_PAGE, 1 - LAYER_2_RAM_SHADOW_PAGE
;       2 - Enable read only 
;       1 - Layer 2 visible
;       0 - Enable mapping for memory writes
; 
; For 5 x 16k Banks, to allow extra paging
;       7-5 reserved
;       4 - 1
;       3 - reserved
;       2-0 Bank offset +0 to +7
L2_ACCESS_PORT:                        equ $123B

TB_BLUE_REGISTER_SELECT                equ $243B
TB_BLUE_REGISTER_ACCESS                equ $253B


;see https://wiki.specnext.dev/Sprite_Status/Slot_Select
SPRITE_STATUS_SLOT_SELECT:              equ $303B

