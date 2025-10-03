;-----------------------------------------------------------------------------------
; 
; Module Sprites
; 
; List of the Sprite IDs in the anagrams.spr sprite-sheet
; 
; Sprites and their palette have been created using Aseprite
; 
; 
;-----------------------------------------------------------------------------------

    module Sprites

QUIT_BUTTON             equ 36
PREVIOUS                equ 37
NEXT                    equ 38
BEER                    equ 39 
BOOK                    equ 40
REROLL                  equ 41
CALCULATOR              equ 42
NOTEPAD                 equ 43
EYE                     equ 44
SCHOLAR                 equ 45


init:
    ;Sprite priority ID=0 on top
    ;Z order: Sprites - ULA - Layer2
    ;Sprites over border and visible
    nextreg SPRITE_LAYERS_SYSTEM,%01001011

    ; $E3 is default transparency
    nextreg SPRITES_TRANSPARENCY_INDEX, TRANSPARENT_INDEX
    call NextSprite.removeAll
    ld a,BANK_SPRITE
    call NextSprite.load

    ld b,PALETTE_COUNT
    ld hl,palette
    call NextSprite.loadPalette
    ret


PALETTE_COUNT           equ 32
TRANSPARENT_INDEX       equ 31

palette:
    ;Palette format
    ; Each entry is 16 bits with only 9 bits used:
    ; B(LSB) RRRGGGBB
    incbin "assets/anagrams.pal"
    endmodule