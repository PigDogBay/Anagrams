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
    include "hardware/Tilemap.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "model/GameId.asm"
    include "model/Grid.asm"
    include "model/Tile.asm"
    include "model/Slot.asm"
    include "model/Board.asm"
    include "Text.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"
    include "utils/Exceptions.asm"
    include "utils/Timing.asm"
    include "game/Game.asm"
    include "game/StateMachine.asm"
    include "game/PlayMouse.asm"
    include "game/Title.asm"
    include "game/Start.asm"
    include "game/Play.asm"
    include "game/Solved.asm"
    IFDEF BATTLEGROUND
        include "game/Battleground.asm"
    ENDIF

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
    nextreg NR_SPRITE_CONTROL,%01001011
    ;Transparent colour for ULA
    ;Should be $E3, (11100011)
    ;But only E7 (11100111) makes bright magenta transparent
    ;Set to 0 (black)
    nextreg NR_GLOBAL_TRANSPARENCY,0
    call Graphics.resetAllClipWindows
    ;Enable layer 2
    nextreg DISPLAY_CONTROL_1,%10000000

    ;set the border color
    BORDER 0
    ld d,0
    call Graphics.setAttributes
    ld d,0
    call Graphics.setPixels

    ld a,30
    call NextSprite.load

    call MouseDriver.init
    jp Game.run

main_loop:
    jr main_loop

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

    ORG Tilemap.START_OF_TILEMAP
    INCBIN "assets/tilemap.map"
    ORG Tilemap.START_OF_TILES
    INCBIN "assets/magnetic.spr"

    ;Load sprite data in 8k banks 30 + 31. Banks placed in MMU slots 0 and 1 
    MMU 0 1,30, 0x0000
    incbin "assets/anagrams.spr"
/*
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
*/

    SAVENEX OPEN "main.nex", main, stack_top, 2
    SAVENEX CORE 3, 1, 5
    SAVENEX CFG 7   ; Border color
    SAVENEX AUTO
    SAVENEX CLOSE

    IFDEF BATTLEGROUND
        DISPLAY "WARRIOR PREPARE FOR BATTLE!!!"
    ELSE
        DISPLAY "Stack top: ", stack_top
        DISPLAY "Code size: ",/D, stack_top - 0x8000," bytes (",/H, stack_top - 0x8000, ")"
    ENDIF
