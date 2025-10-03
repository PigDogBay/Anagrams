       SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUMNEXT

BANK_PUZZLES_START              equ 30
BANK_SPRITE:                    equ 40
BANK_IMAGE_1:                   equ 50
BANK_IMAGE_1_PALETTE:           equ 60

    ORG 0x8000
    include "hardware/PortsRegisters.asm"
    include "hardware/DMA.asm"
    include "hardware/Graphics.asm"
    include "hardware/NextSprite.asm"
    include "hardware/MouseDriver.asm"
    include "hardware/Tilemap.asm"
    include "hardware/Print.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "model/Grid.asm"
    include "model/Puzzles.asm"
    include "model/YearTerm.asm"
    include "model/College.asm"
    include "model/Money.asm"
    include "model/GameId.asm"
    include "model/Tile.asm"
    include "model/Slot.asm"
    include "model/Board.asm"
    include "model/Motion.asm"
    include "model/Time.asm"
    include "model/Lifelines.asm"
    include "game/StateMachine.asm"
    include "game/Sprites.asm"
    include "utils/Maths.asm"
    include "utils/List.asm"
    include "utils/String.asm"
    include "utils/Timing.asm"
    include "utils/ScoresConvert.asm"
    include "animation/Animator.asm"
    include "animation/Flash.asm"
    include "animation/FlashTwo.asm"
    include "animation/FlashSprites.asm"
    include "animation/MoveSprites.asm"
    include "animation/Visibility.asm"
    include "tests/utils/MockExceptions.asm"
    include "tests/Macros.asm"

    ;Test includes
    include "tests/UnitTests.inc"
    include "tests/hardware/MouseDriverTests.asm"
    include "tests/hardware/PrintTests.asm"
    include "tests/model/MouseTests.asm"
    include "tests/model/GridTests.asm"
    include "tests/model/TileTests.asm"
    include "tests/model/SlotTests.asm"
    include "tests/model/SpriteListTests.asm"
    include "tests/model/BoardTests.asm"
    include "tests/model/GameIdTests.asm"
    include "tests/model/PuzzlesTests.asm"
    include "tests/model/CollegeTests.asm"
    include "tests/model/YearTermTests.asm"
    include "tests/model/MoneyTests.asm"
    include "tests/model/MotionTests.asm"
    include "tests/model/TimeTests.asm"
    include "tests/model/LifelinesTests.asm"
    include "tests/utils/MathsTests.asm"
    include "tests/utils/StringTests.asm"
    include "tests/utils/TimingTests.asm"
    include "tests/utils/ExceptionsTests.asm"
    include "tests/utils/ScoresConvertTests.asm"
    include "tests/utils/ListTests.asm"
    include "tests/behaviour/Solving.asm"
    include "tests/gameStates/StateMachineTests.asm"
    include "tests/animation/VisibilityTests.asm"

    ; Initialization routine called before all unit tests are started
    UNITTEST_INITIALIZE
    ; Do your initialization here ...
    ; ...
    ; ...
    ret

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

    ; The stack pointer does not need to be setup explicitly for the unit tests.
    SAVENEX OPEN "tests.nex"
    SAVENEX CORE 3, 1, 5
    SAVENEX CFG 7   ; Border color
    SAVENEX AUTO
    SAVENEX CLOSE

    DISPLAY " **** UNIT TESTS ****"
