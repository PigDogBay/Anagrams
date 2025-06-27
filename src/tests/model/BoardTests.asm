    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Grid

UT_placeTile1:
    //TODO WRITE TEST
    TC_END

UT_bounceTile:
    //TODO WRITE TEST
    TC_END



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
    call Board.snapTileToSlot

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
    call Board.snapTileToSlot

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
