    module TestSuite_Motion

UT_initMoveToXY1:
    ld ix,motion
    ld iy,sprite
    call Motion.initMoveToXY
    TEST_MEMORY_BYTE motion + motionStruct.gameId,42
    TEST_MEMORY_BYTE motion + motionStruct.countY,50
    TEST_MEMORY_BYTE motion + motionStruct.stepY,2
    TEST_MEMORY_WORD motion + motionStruct.countX,100
    TEST_MEMORY_BYTE motion + motionStruct.stepX,1
    TC_END
motion:
    ; gameId, stepX, countX, stepY, countY, delay 
    motionStruct 0, 1, 300, 2, 200, 0 
sprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 1, 200, 100, 0, 0, 42, 0


    endmodule
