    module TestSuite_Slot

UT_createSlots1:
    call Slot.removeAll
    ld c,42
    ld hl,.data
    call Slot.createSlots
    ; gameId will be increased by number of slots created
    nop ; ASSERTION c == 42 + (5 + 8)
    ;Extra slot for the spacer slot
    TEST_MEMORY_BYTE Slot.slotCount,15

    ;Check slotList[3] O
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*3+slotStruct.id,44
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*3+slotStruct.letter,'O'
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*3+slotStruct.tileId,0

    TC_END
.data:
    db "ACORN\nELECTRON",0


UT_justifySlots1:
    ld hl,.data
    call Slot.justifySlots
    nop ; ASSERTION A == Slot.LAYOUT_SLOT_CENTER_COLUMN -2
    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_justifySlots2:
    ld hl,.data
    call Slot.justifySlots
    nop ; ASSERTION A == Slot.LAYOUT_SLOT_CENTER_COLUMN - 4
    TC_END
.data:
    db "SPECTRUM",0

UT_justifySlots3:
    ld hl,.data
    call Slot.justifySlots
    nop ; ASSERTION A == Slot.LAYOUT_SLOT_CENTER_COLUMN - 3
    TC_END
.data:
    db "THE ACE\nOF SPADES",0


UT_slotTile1:
    call Slot.removeAll
    ld c,10
    ld hl,.data
    call Slot.createSlots
    ld a,14
    ld c,42
    call Slot.slotTile

    ;[\n][A][C][O][R][N][\n][E]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*4+slotStruct.tileId,0  ;[R]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*5+slotStruct.tileId,42 ;[N]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*7+slotStruct.tileId,0  ;[E]

    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_unslotTile1:
    call Slot.removeAll
    ld c,10
    ld hl,.data
    call Slot.createSlots
    ld a,14
    ld c,42
    call Slot.slotTile

    ;[\n][A][C][O][R][N][\n][E]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*5+slotStruct.tileId,42 ;[N]

    ld a,42
    call Slot.unslotTile
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*5+slotStruct.tileId,0


    TC_END
.data:
    db "ACORN\nELECTRON",0


    endmodule
