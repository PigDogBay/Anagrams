; Spectrum ROM routines
ROM_CLS:                equ $0daf
ROM_OPEN_CHANNEL:       equ $1601
ROM_PRINT:              equ $203c


;  Ports and registers
;  See https://www.specnext.com/tbblue-io-port-system/'



;  (R/W) 0x07 (07) => Turbo mode:
;  bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz)
;  (00 after a PoR or Hard-reset)
NR_TURBO_CONTROL:                       equ $07

; Sets the layer 2 start 16k bank, for 256x192 requires 3x16k, 320x256 5x16k
LAYER_2_RAM_PAGE:                       equ $12
LAYER_2_RAM_SHADOW_PAGE:                equ $13

;$E3 is the default value for the ULA transparency colour
;Set to $E7 for Bright Magenta (paper 3)
NR_GLOBAL_TRANSPARENCY:                 equ $14

LAYER_2_X_OFFSET:                       equ $16
LAYER_2_Y_OFFSET:                       equ $17

CLIP_WINDOW_LAYER:                      equ $18
CLIP_WINDOW_SPRITES:                    equ $19
CLIP_WINDOW_ULA:                        equ $1A
CLIP_WINDOW_TILEMAP:                    equ $1B
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
NR_SPRITE_CONTROL:                      equ $15

;(W) 0x1C (28) => Clip Window control
;bit 3 - reset the tilemap clip index
;bit 2 - reset the ULA/LoRes clip index.
;bit 1 - reset the sprite clip index.
;bit 0 - reset the Layer 2 clip index.
;Set to $0f to reset all clip indexes.
NR_CLIP_WINDOW_CONTROL:                equ $1C

ACTIVE_VIDEO_LINE_MSB:                 equ $1E
ACTIVE_VIDEO_LINE_LSB:                 equ $1F


MMU_0:                                 equ $50
MMU_1:                                 equ $51
MMU_2:                                 equ $52
MMU_3:                                 equ $53
MMU_4:                                 equ $54
MMU_5:                                 equ $55
MMU_6:                                 equ $56
MMU_7:                                 equ $57

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

;https://wiki.specnext.dev/Display_Control_1_Register
DISPLAY_CONTROL_1:                     equ $69

;$xx6B where xx is program length
DMA_PORT:                              equ $6B

LAYER_2_CONTROL:                       equ $70
LAYER_2_X_OFFSET_MSB:                  equ $71


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

