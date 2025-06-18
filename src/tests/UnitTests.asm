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
    include "Game.asm"
    include "Text.asm"
    include "model/Tile.asm"
    include "utils/Maths.asm"
    include "utils/String.asm"
    include "tests/Macros.asm"

    ;Test includes
    include "tests/UnitTests.inc"
    include "tests/hardware/MouseDriverTests.asm"
    include "tests/model/MouseTests.asm"
    include "tests/model/TileTests.asm"
    include "tests/model/SpriteListTests.asm"
    include "tests/utils/MathsTests.asm"
    include "tests/utils/StringTests.asm"

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
