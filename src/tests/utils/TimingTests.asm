    module TestSuite_Timing


UT_onTick1:
    WRITE_WORD Timing.tickCount,0x41FF
    call Timing.onTick
    TEST_MEMORY_WORD Timing.tickCount,0x4200
    TC_END


UT_startTimer1:
    WRITE_WORD Timing.tickCount,0x4201
    ld ix,.data
    ld hl,0x0441
    call Timing.startTimer
    TEST_MEMORY_WORD .data + timingStruct.duration,0x0441
    TEST_MEMORY_WORD .data + timingStruct.startCount,0x4201
    TEST_MEMORY_WORD .data + timingStruct.endCount,0x4642
    TC_END
.data:
    timingStruct 0,0,0

UT_restartTimer1:
    ld ix,.data
    WRITE_WORD Timing.tickCount,0x0101
    call Timing.restartTimer
    TEST_MEMORY_WORD .data + timingStruct.duration,0x03BA
    TEST_MEMORY_WORD .data + timingStruct.startCount,0x0101
    TEST_MEMORY_WORD .data + timingStruct.endCount,0x04BB
    TC_END
.data:
    timingStruct 0x03BA,0xCAFE,0xBABE

; Duration = 3 ticks
UT_hasTimerElapsed1:
    ld ix,.data
    WRITE_WORD Timing.tickCount,0
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    call Timing.onTick
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    call Timing.onTick
    call Timing.onTick
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ

    TC_END
.data:
    timingStruct 0x03,0,3

; Start < End : Tick count = start Count : still ticking
UT_hasTimerElapsed2:
    ld ix,.data
    WRITE_WORD Timing.tickCount,1000
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 10,1000,1010

; Start < End : Tick count = mid range : still ticking
UT_hasTimerElapsed3:
    ld ix,.data
    WRITE_WORD Timing.tickCount,1005
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 10,1000,1010

; Start < End : Tick count = end Count : elapsed
UT_hasTimerElapsed4:
    ld ix,.data
    WRITE_WORD Timing.tickCount,1010
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ
    TC_END
.data:
    timingStruct 10,1000,1010

; Start < End : Tick count = start Count + 1 : still ticking
UT_hasTimerElapsed5:
    ld ix,.data
    WRITE_WORD Timing.tickCount,1001
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 10,1000,1010

; Start < End : Tick count = end Count + 1 : elapsed
UT_hasTimerElapsed6:
    ld ix,.data
    WRITE_WORD Timing.tickCount,1011
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ
    TC_END
.data:
    timingStruct 10,1000,1010



; End < Start : Tick count = start Count : still ticking
UT_hasTimerElapsed10:
    ld ix,.data
    WRITE_WORD Timing.tickCount,65036
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 1000,65036,500

; End < Start : Tick count = mid range  : still ticking
UT_hasTimerElapsed11:
    ld ix,.data
    WRITE_WORD Timing.tickCount,65535
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 1000,65036,500

; End < Start : Tick count = mid range  : still ticking
UT_hasTimerElapsed12:
    ld ix,.data
    WRITE_WORD Timing.tickCount,0
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 1000,65036,500

; End < Start : Tick count = mid range  : still ticking
UT_hasTimerElapsed13:
    ld ix,.data
    WRITE_WORD Timing.tickCount,200
    call Timing.hasTimerElapsed
    TEST_FLAG_Z
    TC_END
.data:
    timingStruct 1000,65036,500

; End < Start : Tick count = end Count : elapsed
UT_hasTimerElapsed14:
    ld ix,.data
    WRITE_WORD Timing.tickCount,500
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ
    TC_END
.data:
    timingStruct 1000,65036,500

; End < Start : Tick count = startCount-1 : elapsed
UT_hasTimerElapsed15:
    ld ix,.data
    WRITE_WORD Timing.tickCount,65035
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ
    TC_END
.data:
    timingStruct 1000,65036,500

; End == Start == 0: elapsed
UT_hasTimerElapsed16:
    ld ix,.data
    WRITE_WORD Timing.tickCount,499
    call Timing.hasTimerElapsed
    TEST_FLAG_NZ
    TC_END
.data:
    timingStruct 100,0,0
    endmodule