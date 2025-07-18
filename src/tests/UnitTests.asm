       SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUMNEXT

    ORG 0x8000
    include "hardware/PortsRegisters.asm"
    include "hardware/DMA.asm"
    include "hardware/Graphics.asm"
    include "hardware/NextSprite.asm"
    include "hardware/MouseDriver.asm"
    include "model/SpriteList.asm"
    include "model/Mouse.asm"
    include "model/Grid.asm"
    include "model/Puzzles.asm"
    include "model/GameId.asm"
    include "model/Tile.asm"
    include "model/Slot.asm"
    include "model/Board.asm"
    include "model/Motion.asm"
    include "game/StateMachine.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"
    include "utils/Timing.asm"
    include "tests/utils/MockExceptions.asm"
    include "tests/Macros.asm"
    include "tests/model/PuzzleData.asm"

    ;Test includes
    include "tests/UnitTests.inc"
    include "tests/hardware/MouseDriverTests.asm"
    include "tests/model/MouseTests.asm"
    include "tests/model/GridTests.asm"
    include "tests/model/TileTests.asm"
    include "tests/model/SlotTests.asm"
    include "tests/model/SpriteListTests.asm"
    include "tests/model/BoardTests.asm"
    include "tests/model/GameIdTests.asm"
    include "tests/model/PuzzlesTests.asm"
    include "tests/model/MotionTests.asm"
    include "tests/utils/MathsTests.asm"
    include "tests/utils/StringTests.asm"
    include "tests/utils/TimingTests.asm"
    include "tests/utils/ExceptionsTests.asm"
    include "tests/behaviour/Solving.asm"
    include "tests/gameStates/StateMachineTests.asm"

    ; Initialization routine called before all unit tests are started
    UNITTEST_INITIALIZE
    ; Do your initialization here ...
    ; ...
    ; ...
    ret


    ; The stack pointer does not need to be setup explicitly for the unit tests.
    SAVENEX OPEN "tests.nex"
    SAVENEX CORE 3, 1, 5
    SAVENEX CFG 7   ; Border color
    SAVENEX AUTO
    SAVENEX CLOSE

    DISPLAY " **** UNIT TESTS ****"
