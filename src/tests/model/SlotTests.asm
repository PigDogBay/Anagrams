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


    ;add some slots
    ;IX data tile sprite
    ;IY data slot sprite
    ;call Slot.snapTileToSlot
    ;check tiles XY
    ;check Slot.tileId
UT_snapTileToSlot1:
    call Slot.removeAll
    ld c,100
    ld hl,.data
    call Slot.createSlots
    ld ix, .tileSprite
    ld iy, .slotSprite
    call Slot.snapTileToSlot

    TEST_MEMORY_WORD .tileSprite + spriteItem.x,101
    TEST_MEMORY_BYTE .tileSprite + spriteItem.y,81
    ld a,101
    call Slot.find
    ld ix,hl
    ld a,(ix+slotStruct.tileId)
    nop ;ASSERTION A == 42

    TC_END
.data:
    db "ACORN",0
.tileSprite:
    spriteItem 0,160,128,0,0,42,0
;gameId = 'C' slot
.slotSprite:
    spriteItem 1,100,80,0,0,101,0


    ;Null Pointer test - IY has invalid game ID (slot ID)
    ;For now function just exits when it gets the null pointer
UT_snapTileToSlot2:
    call Slot.removeAll
    ld c,100
    ld hl,.data
    call Slot.createSlots
    ld ix, .tileSprite
    ld iy, .slotSprite
    call Slot.snapTileToSlot

    TEST_MEMORY_WORD .tileSprite + spriteItem.x,101
    TEST_MEMORY_BYTE .tileSprite + spriteItem.y,81
    ld a,101
    call Slot.find
    ld ix,hl
    ld a,(ix+slotStruct.tileId)
    ;Won't have found the slot, so tileID will still be 0
    nop ;ASSERTION A == 0

    TC_END
.data:
    db "ACORN",0
.tileSprite:
    spriteItem 0,160,128,0,0,42,0
;gameId = 'C' slot
.slotSprite:
    spriteItem 1,100,80,0,0,200,0






    endmodule
