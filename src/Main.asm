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

SPRITE_PATTERN_COUNT:         equ 30

;-----------------------------------------------------------------------------------
; 
; Include modules
; 
;-----------------------------------------------------------------------------------
    include "hardware/PortsRegisters.asm"
    include "hardware/DMA.asm"
    include "hardware/Graphics.asm"
    include "hardware/NextSprite.asm"
    include "hardware/MouseDriver.asm"
    include "hardware/Tilemap.asm"
    include "hardware/Print.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "model/Puzzles.asm"
    include "model/PuzzleData.asm"
    include "model/GameId.asm"
    include "model/Grid.asm"
    include "model/Tile.asm"
    include "model/Slot.asm"
    include "model/Board.asm"
    include "model/Motion.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"
    include "utils/Exceptions.asm"
    include "utils/Timing.asm"
    include "game/Game.asm"
    include "game/StateMachine.asm"
    include "game/PlayMouse.asm"
    include "game/states/Title.asm"
    include "game/states/LevelSelect.asm"
    include "game/states/Round.asm"
    include "game/states/Start.asm"
    include "game/states/Play.asm"
    include "game/states/Solved.asm"
    include "game/states/ConfirmQuit.asm"
    include "game/states/LifelineClue.asm"
    include "game/states/LifelineTile.asm"
    include "game/states/LifelineSlot.asm"
    include "game/states/LifelineSolve.asm"
    include "animation/Animator.asm"
    include "animation/Flash.asm"
    include "animation/FlashTwo.asm"
    include "animation/FlashSprites.asm"
    include "animation/MoveSprites.asm"
    include "animation/Visibility.asm"
    IFDEF BATTLEGROUND
        include "game/states/Battleground.asm"
    ENDIF

;-----------------------------------------------------------------------------------
; 
; Entry Function: main()
; 
; Code execution starts here.  Initializes the Next's hardware and then jumps into
; the game's state machine.
;
;-----------------------------------------------------------------------------------
main:

    ; Disable interrupts
    di
    ld sp,stack_top

    ;Set clock to 28MHz
    nextreg CPU_SPEED,3

    ;Set fallback colour to be black
    nextreg TRANSPARENCY_COLOUR_FALLBACK,0
    call Graphics.resetAllClipWindows

    ;TODO Set up each layer's palette
    ;
    ; Layer2
    ;
    ld a,0
    call Graphics.fillLayer2_320

    ;
    ; ULA
    ;

    ;Transparent colour for ULA
    ;Default is $E3, (11100011)
    ;But only E7 (11100111) makes bright magenta transparent
    ;Set to 0 (black)
    nextreg GLOBAL_TRANSPARENCY,0

    ;set the border color
    BORDER 0
    ld d,0
    call Graphics.setAttributes
    ld d,0
    call Graphics.setPixels

    ;
    ; Tilemap
    ;
    call Tilemap.init

    ;
    ; Sprites
    ;

    ;Sprite priority ID=0 on top
    ;Z order: Sprites - ULA - Layer2
    ;Sprites over border and visible
    nextreg SPRITE_LAYERS_SYSTEM,%01001011

    ; $E3 is default transparency
    nextreg SPRITES_TRANSPARENCY_INDEX, $E3
    call NextSprite.removeAll
    ld a,SPRITE_PATTERN_COUNT
    call NextSprite.load


    call MouseDriver.init
    jp Game.run

main_loop:
    jr main_loop



;-----------------------------------------------------------------------------------
; 
; Stack
;
;-----------------------------------------------------------------------------------

; Stack: this area is reserved for the stack
STACK_SIZE: equ 100    ; in words


; Reserve stack space
    defw 0  ; WPMEM, 2
stack_bottom:
    defs    STACK_SIZE*2, 0
stack_top:
    ;defw 0
    defw 0  ; WPMEM, 2


;-----------------------------------------------------------------------------------
; 
; NEX File
;
;-----------------------------------------------------------------------------------
    ORG 0x5c00
    INCBIN "assets/sysvars.bin" ; 0x5c00-0x5c3a

    ORG Tilemap.START_OF_TILES
    INCBIN "assets/font.spr"

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

;-----------------------------------------------------------------------------------
; 
; Compilation Messages
;
;-----------------------------------------------------------------------------------
    IFDEF BATTLEGROUND
        DISPLAY "WARRIOR PREPARE FOR BATTLE!!!"
    ELSE
        DISPLAY "Stack top: ", stack_top
        DISPLAY "Code size: ",/D, stack_top - 0x8000," bytes (",/H, stack_top - 0x8000, ")"
    ENDIF
