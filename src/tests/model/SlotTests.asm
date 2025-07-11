    module TestSuite_Slot

UT_createSlots1:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots
    ;Extra slot for the spacer slot
    TEST_MEMORY_BYTE Slot.slotCount,15

    ;Check slotList[3] O
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
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots
    ld a,(Slot.slotList + slotStruct*5 + slotStruct.id)
    ld c,42
    call Slot.slotTile

    ;[\n][A][C][O][R][N][\n][E]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*4+slotStruct.tileId,0  ;[R]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*5+slotStruct.tileId,42  ;[N]
    TEST_MEMORY_BYTE Slot.slotList+slotStruct*7+slotStruct.tileId,0  ;[E]

    CHECK_SLOT_NOT_FOUND_NOT_CALLED
    TC_END
.data:
    db "ACORN\nELECTRON",0

;Test SlotNotFound exception is thrown
UT_slotTile2:
    EXCEPTIONS_CLEAR
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots
    ;Slot ID 85 hopefully should not exist
    ld a,85
    ld c,15
    call Slot.slotTile
    CHECK_SLOT_NOT_FOUND_CALLED
    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_unslotTile1:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots
    ld a,(Slot.slotList + slotStruct*5 + slotStruct.id)
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



;-----------------------------------------------------------------------------------
;
; Function: findByLetter(uint8 letter, uint8 index) -> uint16
;
; Finds the slotStruct with matching letter, starting from the specified index
;
; In:    D - Letter
;        E - starting index
; Out:   HL - ptr to slot's struct, null if not found
;        A - index of matching slot
;
; Dirty: A, HL
;
;-----------------------------------------------------------------------------------
UT_findByLetter1:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'O'
    ld e,0
    call Slot.findByLetter
    nop ; ASSERTION A == 3
    nop ; ASSERTION HL == Slot.slotList + 3*3

    TC_END
.data:
    db "ACORN\nELECTRON",0


UT_findByLetter2:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'O'
    ld e,4
    call Slot.findByLetter
    nop ; ASSERTION A == 13
    nop ; ASSERTION HL == Slot.slotList + 13*3

    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_findByLetter3:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'O'
    ld e,3
    call Slot.findByLetter
    nop ; ASSERTION A == 3
    nop ; ASSERTION HL == Slot.slotList + 3*3

    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_findByLetter4:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'N'
    ld e,6
    call Slot.findByLetter
    nop ; ASSERTION A == 14
    nop ; ASSERTION HL == Slot.slotList + 14*3

    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_findByLetter5:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'A'
    ld e,0
    call Slot.findByLetter
    nop ; ASSERTION A == 1
    nop ; ASSERTION HL == Slot.slotList + 1*3

    TC_END
.data:
    db "ACORN\nELECTRON",0

UT_findByLetter6:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    ld d,'A'
    ld e,2
    call Slot.findByLetter
    nop ; ASSERTION A == 0
    nop ; ASSERTION HL == 0

    TC_END
.data:
    db "ACORN\nELECTRON",0

    endmodule
