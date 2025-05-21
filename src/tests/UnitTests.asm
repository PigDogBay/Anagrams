       SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUMNEXT

    ORG 0x8000
    include "Hardware.asm"
    include "Graphics.asm"
    include "Sprite.asm"
    include "Mouse.asm"
    include "Game.asm"
    include "Text.asm"

    ;Test includes
    include "tests/UnitTests.inc"
    include "tests/SpriteTests.asm"

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
