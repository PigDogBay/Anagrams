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
    call graphics.resetAllClipWindows
    ;Enable layer 2
    nextreg DISPLAY_CONTROL_1,%10000000

    ;set the border color
    BORDER 0
    CLS
    ld d,45
    call graphics.clearLayer2
    call graphics.layer2Test320
    call NextSprite.removeAll

    call MouseDriver.init
    call game.init
    call game.run

main_loop:
    jr main_loop


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

    SAVENEX OPEN "main.nex", main, stack_top, 2
    SAVENEX CORE 3, 1, 5
    SAVENEX CFG 7   ; Border color
    SAVENEX AUTO
    SAVENEX CLOSE
