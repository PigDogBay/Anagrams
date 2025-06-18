    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUMNEXT

    ORG 0x8000

    ; Resources
    ; Next/Docs/zx-next-dev-guide-r3.pdf
    ; https://luckyredfish.com/patricias-z80-snippets/
    ; https://specnext.dev/ 
    ; http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum-next/assembly-language/z80-library-routines
    ; https://zx.remysharp.com/sprites/#sprite-editor
    ; https://damieng.com/typography/zx-origins/
    

;===========================================================================
; Include modules
;===========================================================================
    include "hardware/PortsRegisters.asm"
    include "hardware/DMA.asm"
    include "hardware/Graphics.asm"
    include "hardware/NextSprite.asm"
    include "hardware/MouseDriver.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "Game.asm"
    include "Text.asm"
    include "model/Tile.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"


;===========================================================================
; main routine - the code execution starts here.
; Sets up the new interrupt routine, the memory
; banks and jumps to the start loop.
;===========================================================================

main:

    ; Disable interrupts
    di
    ld sp,stack_top

    ;Set clock to 28MHz
    nextreg NR_TURBO_CONTROL,3
    nextreg NR_SPRITE_CONTROL,%01000011
    ;Transparent colour for ULA
    nextreg NR_GLOBAL_TRANSPARENCY,$E3
    call Graphics.resetAllClipWindows
    ;Enable layer 2
    nextreg DISPLAY_CONTROL_1,%10000000

    ;set the border color
    BORDER 0
    CLS
    ld a,5
    call Graphics.fillLayer2_320
    call Graphics.layer2Test320
    call NextSprite.removeAll
    call titleScreen

    call MouseDriver.init
    call game.init
    call game.run

main_loop:
    jr main_loop

;-----------------------------------------------------------------------------------
; 
; To create Layer 2 images, 320x256 256 colours
; 
; convert oxford-small.jpg -colors 256 -depth 8 -compress none BMP3:oxford.bmp
; ~/work/Next/tools/Gfx2Next/build/gfx2next -bitmap -preview -bitmap-y -pal-std oxford.bmp
; split -b 8k -d oxford.nxi bg_
; for file in bg_*; do mv "$file" "$file.nxi"; done
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

    ; 16k Bank, first 8k bank of image is at 40
    ; So 16k bank is 40/2 = 20
    nextreg LAYER_2_RAM_PAGE, 20
    ret

;===========================================================================
; Stack.
;===========================================================================


; Stack: this area is reserved for the stack
STACK_SIZE: equ 100    ; in words


; Reserve stack space
    defw 0  ; WPMEM, 2
stack_bottom:
    defs    STACK_SIZE*2, 0
stack_top:
    ;defw 0
    defw 0  ; WPMEM, 2

    ORG 0x5c00
    INCBIN "assets/sysvars.bin" ; 0x5c00-0x5c3a

    ;Load sprite data in 8k banks 30 + 31. Banks placed in MMU slots 0 and 1 
    MMU 0 1,30, 0x0000
    incbin "assets/anagrams.spr"

    MMU 0,40, 0x0000
    incbin "assets/titleScreen/bg_00.nxi"
    MMU 0,41, 0x0000
    incbin "assets/titleScreen/bg_01.nxi"
    MMU 0,42, 0x0000
    incbin "assets/titleScreen/bg_02.nxi"
    MMU 0,43, 0x0000
    incbin "assets/titleScreen/bg_03.nxi"
    MMU 0,44, 0x0000
    incbin "assets/titleScreen/bg_04.nxi"
    MMU 0,45, 0x0000
    incbin "assets/titleScreen/bg_05.nxi"
    MMU 0,46, 0x0000
    incbin "assets/titleScreen/bg_06.nxi"
    MMU 0,47, 0x0000
    incbin "assets/titleScreen/bg_07.nxi"
    MMU 0,48, 0x0000
    incbin "assets/titleScreen/bg_08.nxi"
    MMU 0,49, 0x0000
    incbin "assets/titleScreen/bg_09.nxi"
    MMU 0,50, 0x0000
    incbin "assets/titleScreen/bg.nxp"

    SAVENEX OPEN "main.nex", main, stack_top, 2
    SAVENEX CORE 3, 1, 5
    SAVENEX CFG 7   ; Border color
    SAVENEX AUTO
    SAVENEX CLOSE
