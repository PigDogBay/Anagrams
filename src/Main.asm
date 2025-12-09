    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUMNEXT
    DEFINE BUILD_2MB
    DEFINE DEBUG_MODE

    DEFINE VERSION "v2.00"

    ORG 0x8000

    ; Resources
    ; https://z00m128.github.io/sjasmplus/documentation.html
    ; Next/Docs/zx-next-dev-guide-r3.pdf
    ; https://luckyredfish.com/patricias-z80-snippets/
    ; https://specnext.dev/ 
    ; http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum-next/assembly-language/z80-library-routines
    ; https://zx.remysharp.com/sprites/#sprite-editor
    ; https://damieng.com/typography/zx-origins/
    ;  - Tile font Calstone
    ;  - Text font based on Truffle Shuffle

BANK_PUZZLES_START              equ 30
BANK_SPRITE:                    equ 40
BANK_SOUND_EFFECTS              equ 50
BANK_SOUND_TRACK1               equ 54
BANK_SOUND_TRACK2               equ 56
BANK_SOUND_TRACK3               equ 58
BANK_SOUND_TRACK4               equ 60
BANK_SOUND_TRACK5               equ 62

BANK_IMAGE_PALETTE:             equ 69
BANK_IMAGE_TITLE                equ 70
BANK_IMAGE_DROPOUT              equ 80
BANK_IMAGE_HILARY               equ 100
BANK_IMAGE_MICHAELMAS           equ 110
BANK_IMAGE_PROSPECTUS           equ 150
BANK_IMAGE_ROUND                equ 120
BANK_IMAGE_TRINITY              equ 130
BANK_IMAGE_WIN                  equ 140

;Image remapping
    IFDEF BUILD_2MB
    ;Use all backdrops for 2MB builds
IMAGE_TITLE                equ BANK_IMAGE_TITLE
IMAGE_PROSPECTUS           equ BANK_IMAGE_TRINITY
IMAGE_HILARY               equ BANK_IMAGE_PROSPECTUS
IMAGE_MICHAELMAS           equ BANK_IMAGE_MICHAELMAS
IMAGE_TRINITY              equ BANK_IMAGE_ROUND
IMAGE_ROUND                equ BANK_IMAGE_HILARY
IMAGE_DROPOUT              equ BANK_IMAGE_DROPOUT
IMAGE_WIN                  equ BANK_IMAGE_WIN
    ELSE
    ;Only use 1 backdrop for 1MB builds
IMAGE_TITLE                equ BANK_IMAGE_TITLE
IMAGE_PROSPECTUS           equ BANK_IMAGE_TITLE
IMAGE_HILARY               equ BANK_IMAGE_TITLE
IMAGE_MICHAELMAS           equ BANK_IMAGE_TITLE
IMAGE_TRINITY              equ BANK_IMAGE_TITLE
IMAGE_ROUND                equ BANK_IMAGE_TITLE
IMAGE_DROPOUT              equ BANK_IMAGE_TITLE
IMAGE_WIN                  equ BANK_IMAGE_TITLE
    ENDIF ;BUILD_2MB



;-----------------------------------------------------------------------------------
; 
; Include modules
; 
;-----------------------------------------------------------------------------------
    include "hardware/PortsRegisters.asm"
    include "utils/Timing.asm"
    include "hardware/DMA.asm"
    include "hardware/Graphics.asm"
    include "hardware/NextSprite.asm"
    include "hardware/MouseDriver.asm"
    include "hardware/Tilemap.asm"
    include "hardware/Print.asm"
    include "hardware/Keyboard.asm"
    include "hardware/Joystick.asm"
    include "hardware/NextDAW.asm"
    ;include "hardware/DummyNextDAW.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "model/Puzzles.asm"
    include "model/YearTerm.asm"
    include "model/College.asm"
    include "model/GameId.asm"
    include "model/Grid.asm"
    include "model/Tile.asm"
    include "model/Slot.asm"
    include "model/Board.asm"
    include "model/Motion.asm"
    include "model/Time.asm"
    include "model/GamePhases.asm"
    include "model/Lifelines.asm"
    include "model/RoundVM.asm"
    include "model/Cheatcode.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"
    include "utils/Exceptions.asm"
    include "utils/ScoresConvert.asm"
    include "utils/List.asm"
    include "animation/Animator.asm"
    include "animation/Flash.asm"
    include "animation/FlashTwo.asm"
    include "animation/FlashSprites.asm"
    include "animation/MoveSprites.asm"
    include "animation/Visibility.asm"
    include "animation/ClearText.asm"
    include "animation/HoldPalette.asm"
    include "game/Game.asm"
    include "game/StateMachine.asm"
    include "game/states/Transition.asm"
    include "game/PlayMouse.asm"
    include "game/Sound.asm"
    include "game/Sprites.asm"
    include "game/states/Title.asm"
    include "game/states/Prospectus.asm"
    include "game/states/Round.asm"
    include "game/states/Start.asm"
    include "game/states/Play.asm"
    include "game/states/Solved.asm"
    include "game/states/LifelineClue.asm"
    include "game/states/LifelineTile.asm"
    include "game/states/LifelineSlot.asm"
    include "game/states/LifelineSolve.asm"
    include "game/states/GameOver.asm"
    include "game/states/Win.asm"
    IFDEF BATTLEGROUND
        include "game/states/PuzzleViewer.asm"
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

    ;Stop Copper, set CPC to 0
    nextreg $61,0
    nextreg $62,0

    ;Set fallback colour to be black (RRRGGGBB)
    ;This acts as the border color
    nextreg TRANSPARENCY_COLOUR_FALLBACK,%00000000
    call Graphics.resetAllClipWindows


    ;
    ; Layer2
    ;
    ;Enable and fill with 0
    ld a,0
    call Graphics.fillLayer2_320

    ; Load palette for screen backdrops
    nextreg MMU_0, BANK_IMAGE_PALETTE
    ld hl,0
    ld b,255
    call Graphics.loadLayer2_9BitPalette
    ; Restore ROM
    nextreg MMU_0, $FF


    ;
    ; ULA
    ;
    ;Default value
    call Graphics.loadULAPalette
    nextreg PALETTE_ULA_INK_COLOR_MASK,7
    nextreg ULA_CONTROL,0

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
    call Sprites.init

    call MouseDriver.init
    call Sound.init

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

    ;Place NextDAW in top 8K
    org $E000
    INCBIN "assets/sound/NextDAW_RuntimePlayer_E000.bin"

    ORG Tilemap.START_OF_TILES
    INCBIN "assets/font.spr"
    ;SOLID BLACK TILE - 32 bytes
    defs 32,0

    ;Load sprite data in 8k banks 30 + 31. Banks placed in MMU slots 0 and 1 
    MMU 0 1,BANK_SPRITE, 0x0000
    incbin "assets/anagrams.spr"

    MMU 0, BANK_SOUND_EFFECTS, 0x0000
    incbin "assets/sound/SFX.NFX"
    MMU 0 1, BANK_SOUND_TRACK1, 0x0000
    incbin "assets/sound/GrangeHill.NDR"
    MMU 0 1, BANK_SOUND_TRACK2, 0x0000
    incbin "assets/sound/OdeToJoy.NDR"
    MMU 0 1, BANK_SOUND_TRACK3, 0x0000
    incbin "assets/sound/AirOn.NDR"
    MMU 0 1, BANK_SOUND_TRACK4, 0x0000
    incbin "assets/sound/Boat.NDR"
    MMU 0 1, BANK_SOUND_TRACK5, 0x0000
    incbin "assets/sound/No21-2nd.NDR"


    MMU 0,BANK_PUZZLES_START + CAT_FRESHERS, 0x0000
    include "puzzles/Freshers.asm"
    MMU 0,BANK_PUZZLES_START + CAT_MUSIC, 0x0000
    include "puzzles/Music.asm"
    MMU 0,BANK_PUZZLES_START + CAT_SCIENCE, 0x0000
    include "puzzles/Science.asm"
    MMU 0,BANK_PUZZLES_START + CAT_FILM, 0x0000
    include "puzzles/FilmTv.asm"
    MMU 0,BANK_PUZZLES_START + CAT_WORLD, 0x0000
    include "puzzles/World.asm"
    MMU 0,BANK_PUZZLES_START + CAT_GAMES, 0x0000
    include "puzzles/GamesTech.asm"
    MMU 0,BANK_PUZZLES_START + CAT_HISTORY, 0x0000
    include "puzzles/History.asm"

    MMU 0,BANK_IMAGE_TITLE, 0x0000
    incbin "assets/title/title_0.nxi"
    MMU 0,BANK_IMAGE_TITLE + 1, 0x0000
    incbin "assets/title/title_1.nxi"
    MMU 0,BANK_IMAGE_TITLE + 2, 0x0000
    incbin "assets/title/title_2.nxi"
    MMU 0,BANK_IMAGE_TITLE + 3, 0x0000
    incbin "assets/title/title_3.nxi"
    MMU 0,BANK_IMAGE_TITLE + 4, 0x0000
    incbin "assets/title/title_4.nxi"
    MMU 0,BANK_IMAGE_TITLE + 5, 0x0000
    incbin "assets/title/title_5.nxi"
    MMU 0,BANK_IMAGE_TITLE + 6, 0x0000
    incbin "assets/title/title_6.nxi"
    MMU 0,BANK_IMAGE_TITLE + 7, 0x0000
    incbin "assets/title/title_7.nxi"
    MMU 0,BANK_IMAGE_TITLE + 8, 0x0000
    incbin "assets/title/title_8.nxi"
    MMU 0,BANK_IMAGE_TITLE + 9, 0x0000
    incbin "assets/title/title_9.nxi"

    MMU 0,BANK_IMAGE_PALETTE, 0x0000
    incbin "assets/layer2.nxp"

    IFDEF BUILD_2MB
        MMU 0,BANK_IMAGE_DROPOUT, 0x0000
        incbin "assets/dropout/dropout_0.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 1, 0x0000
        incbin "assets/dropout/dropout_1.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 2, 0x0000
        incbin "assets/dropout/dropout_2.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 3, 0x0000
        incbin "assets/dropout/dropout_3.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 4, 0x0000
        incbin "assets/dropout/dropout_4.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 5, 0x0000
        incbin "assets/dropout/dropout_5.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 6, 0x0000
        incbin "assets/dropout/dropout_6.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 7, 0x0000
        incbin "assets/dropout/dropout_7.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 8, 0x0000
        incbin "assets/dropout/dropout_8.nxi"
        MMU 0,BANK_IMAGE_DROPOUT + 9, 0x0000
        incbin "assets/dropout/dropout_9.nxi"

        MMU 0,BANK_IMAGE_HILARY, 0x0000
        incbin "assets/hilary/hilary_0.nxi"
        MMU 0,BANK_IMAGE_HILARY + 1, 0x0000
        incbin "assets/hilary/hilary_1.nxi"
        MMU 0,BANK_IMAGE_HILARY + 2, 0x0000
        incbin "assets/hilary/hilary_2.nxi"
        MMU 0,BANK_IMAGE_HILARY + 3, 0x0000
        incbin "assets/hilary/hilary_3.nxi"
        MMU 0,BANK_IMAGE_HILARY + 4, 0x0000
        incbin "assets/hilary/hilary_4.nxi"
        MMU 0,BANK_IMAGE_HILARY + 5, 0x0000
        incbin "assets/hilary/hilary_5.nxi"
        MMU 0,BANK_IMAGE_HILARY + 6, 0x0000
        incbin "assets/hilary/hilary_6.nxi"
        MMU 0,BANK_IMAGE_HILARY + 7, 0x0000
        incbin "assets/hilary/hilary_7.nxi"
        MMU 0,BANK_IMAGE_HILARY + 8, 0x0000
        incbin "assets/hilary/hilary_8.nxi"
        MMU 0,BANK_IMAGE_HILARY + 9, 0x0000
        incbin "assets/hilary/hilary_9.nxi"

        MMU 0,BANK_IMAGE_MICHAELMAS, 0x0000
        incbin "assets/michaelmas/michaelmas_0.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 1, 0x0000
        incbin "assets/michaelmas/michaelmas_1.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 2, 0x0000
        incbin "assets/michaelmas/michaelmas_2.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 3, 0x0000
        incbin "assets/michaelmas/michaelmas_3.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 4, 0x0000
        incbin "assets/michaelmas/michaelmas_4.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 5, 0x0000
        incbin "assets/michaelmas/michaelmas_5.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 6, 0x0000
        incbin "assets/michaelmas/michaelmas_6.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 7, 0x0000
        incbin "assets/michaelmas/michaelmas_7.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 8, 0x0000
        incbin "assets/michaelmas/michaelmas_8.nxi"
        MMU 0,BANK_IMAGE_MICHAELMAS + 9, 0x0000
        incbin "assets/michaelmas/michaelmas_9.nxi" 

        MMU 0,BANK_IMAGE_PROSPECTUS, 0x0000
        incbin "assets/prospectus/prospectus_0.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 1, 0x0000
        incbin "assets/prospectus/prospectus_1.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 2, 0x0000
        incbin "assets/prospectus/prospectus_2.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 3, 0x0000
        incbin "assets/prospectus/prospectus_3.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 4, 0x0000
        incbin "assets/prospectus/prospectus_4.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 5, 0x0000
        incbin "assets/prospectus/prospectus_5.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 6, 0x0000
        incbin "assets/prospectus/prospectus_6.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 7, 0x0000
        incbin "assets/prospectus/prospectus_7.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 8, 0x0000
        incbin "assets/prospectus/prospectus_8.nxi"
        MMU 0,BANK_IMAGE_PROSPECTUS + 9, 0x0000
        incbin "assets/prospectus/prospectus_9.nxi"

        MMU 0,BANK_IMAGE_ROUND, 0x0000
        incbin "assets/round/round_0.nxi"
        MMU 0,BANK_IMAGE_ROUND + 1, 0x0000
        incbin "assets/round/round_1.nxi"
        MMU 0,BANK_IMAGE_ROUND + 2, 0x0000
        incbin "assets/round/round_2.nxi"
        MMU 0,BANK_IMAGE_ROUND + 3, 0x0000
        incbin "assets/round/round_3.nxi"
        MMU 0,BANK_IMAGE_ROUND + 4, 0x0000
        incbin "assets/round/round_4.nxi"
        MMU 0,BANK_IMAGE_ROUND + 5, 0x0000
        incbin "assets/round/round_5.nxi"
        MMU 0,BANK_IMAGE_ROUND + 6, 0x0000
        incbin "assets/round/round_6.nxi"
        MMU 0,BANK_IMAGE_ROUND + 7, 0x0000
        incbin "assets/round/round_7.nxi"
        MMU 0,BANK_IMAGE_ROUND + 8, 0x0000
        incbin "assets/round/round_8.nxi"
        MMU 0,BANK_IMAGE_ROUND + 9, 0x0000
        incbin "assets/round/round_9.nxi"

        MMU 0,BANK_IMAGE_TRINITY, 0x0000
        incbin "assets/trinity/trinity_0.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 1, 0x0000
        incbin "assets/trinity/trinity_1.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 2, 0x0000
        incbin "assets/trinity/trinity_2.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 3, 0x0000
        incbin "assets/trinity/trinity_3.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 4, 0x0000
        incbin "assets/trinity/trinity_4.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 5, 0x0000
        incbin "assets/trinity/trinity_5.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 6, 0x0000
        incbin "assets/trinity/trinity_6.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 7, 0x0000
        incbin "assets/trinity/trinity_7.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 8, 0x0000
        incbin "assets/trinity/trinity_8.nxi"
        MMU 0,BANK_IMAGE_TRINITY + 9, 0x0000
        incbin "assets/trinity/trinity_9.nxi"

        MMU 0,BANK_IMAGE_WIN, 0x0000
        incbin "assets/win/win_0.nxi"
        MMU 0,BANK_IMAGE_WIN + 1, 0x0000
        incbin "assets/win/win_1.nxi"
        MMU 0,BANK_IMAGE_WIN + 2, 0x0000
        incbin "assets/win/win_2.nxi"
        MMU 0,BANK_IMAGE_WIN + 3, 0x0000
        incbin "assets/win/win_3.nxi"
        MMU 0,BANK_IMAGE_WIN + 4, 0x0000
        incbin "assets/win/win_4.nxi"
        MMU 0,BANK_IMAGE_WIN + 5, 0x0000
        incbin "assets/win/win_5.nxi"
        MMU 0,BANK_IMAGE_WIN + 6, 0x0000
        incbin "assets/win/win_6.nxi"
        MMU 0,BANK_IMAGE_WIN + 7, 0x0000
        incbin "assets/win/win_7.nxi"
        MMU 0,BANK_IMAGE_WIN + 8, 0x0000
        incbin "assets/win/win_8.nxi"
        MMU 0,BANK_IMAGE_WIN + 9, 0x0000
        incbin "assets/win/win_9.nxi"
    ENDIF

    SAVENEX OPEN "main.nex", main, stack_top, 0
    SAVENEX CORE 3, 1, 5
    IFDEF BUILD_2MB
        SAVENEX CFG 7, 0, 0, 1   ; Border color, 0,0, 1 = 2Mb Ram required
    ELSE
        SAVENEX CFG 7
    ENDIF
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
