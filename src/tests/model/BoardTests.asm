    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Board

UT_placeTile1:
    //TODO WRITE TEST
    TC_END

UT_bounceTile:
    //TODO WRITE TEST
    TC_END

;No tile slotted
UT_isSlotSolved1:
    ld iy, Slot.slotList
    ld (iy + slotStruct.id),2
    ld (iy + slotStruct.letter),"X"
    ld (iy + slotStruct.tileId),0
    call Board.isSlotSolved
    nop ; ASSERTION A==0
    TC_END

;Space tile slotted - always solved
UT_isSlotSolved2:
    ld iy, Slot.slotList
    ld (iy + slotStruct.id),0
    ld (iy + slotStruct.letter),CHAR_SPACE
    ld (iy + slotStruct.tileId),0
    call Board.isSlotSolved
    nop ; ASSERTION A==1

    TC_END

;Newline tile slotted - always solved
UT_isSlotSolved3:
    ld iy, Slot.slotList
    ld (iy + slotStruct.id),0
    ld (iy + slotStruct.letter),CHAR_NEWLINE
    ld (iy + slotStruct.tileId),0
    call Board.isSlotSolved
    nop ; ASSERTION A==1

    TC_END

;Correct tile slotted
UT_isSlotSolved4:
    call Tile.removeAll
    ld c,100
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"R"
    ld (iy + slotStruct.tileId),103
    call Board.isSlotSolved
    nop ; ASSERTION A==1

    TC_END
.data:
    db "ACORN\nELECTRON",0


;Case 2: wrong tile slotted
UT_isSlotSolved5:
    call Tile.removeAll
    ld c,100
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"N"
    ld (iy + slotStruct.tileId),103
    call Board.isSlotSolved
    nop ; ASSERTION A==0

    TC_END
.data:
    db "ACORN\nELECTRON",0


;Case 4: non-existant tile slotted
UT_isSlotSolved6:
    EXCEPTIONS_CLEAR
    call Tile.removeAll
    ld c,100
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"R"
    ld (iy + slotStruct.tileId),200
    call Board.isSlotSolved
    CHECK_TILE_NOT_FOUND_CALLED
.data:
    db "ACORN\nELECTRON",0
    TC_END

;Case 4: non-existant tile slotted
UT_isSolved1:
    call Tile.removeAll
    
    ld c,100
    ld hl,.data
    call Slot.createSlots
    
    ld c,200
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"R"
    ld (iy + slotStruct.tileId),200
    call Board.isSlotSolved
.data:
    db "ACORN\nELECTRON",0
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


UT_findEmptyMatchingSlot1:
    call Tile.removeAll
    call Slot.removeAll
    
    ld c,100
    ld hl,.data
    call Slot.createSlots
    
    ld c,200
    ld hl,.data
    call Tile.createTiles

    FIRST_TILE ix
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ld a,(iy + slotStruct.letter)
    nop ; ASSERTION A == 'M'
.data:
    db "MISSILE\nCOMMAND",0
    TC_END

;Find last
UT_findEmptyMatchingSlot2:
    call Tile.removeAll
    call Slot.removeAll
    
    ld c,100
    ld hl,.data
    call Slot.createSlots
    
    ld c,200
    ld hl,.data
    call Tile.createTiles

    TILE_AT ix, 13
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ld a,(iy + slotStruct.letter)
    nop ; ASSERTION A == 'D'
.data:
    db "MISSILE\nCOMMAND",0
    TC_END


;Non matching tile
UT_findEmptyMatchingSlot3:
    call Tile.removeAll
    call Slot.removeAll
    
    ld c,100
    ld hl,.data
    call Slot.createSlots
    
    ld c,200
    ld hl,.data
    call Tile.createTiles

    FIRST_TILE ix
    ld (ix+tileStruct.letter),"?"
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A==0

.data:
    db "MISSILE\nCOMMAND",0
    TC_END

;Occupied tile
UT_findEmptyMatchingSlot4:
    call Tile.removeAll
    call Slot.removeAll
    
    ld c,100
    ld hl,.data
    call Slot.createSlots
    
    ld c,200
    ld hl,.data
    call Tile.createTiles

    ;Third M (index 10)
    TILE_AT ix, 10
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ;Check it chose the first M slot
    ld a, (iy+slotStruct.id)
    nop ; ASSERTION A==100

    ;Place tile
    ld a,(ix+tileStruct.id)
    ld (iy+slotStruct.tileId),a


    ;First M tile
    FIRST_TILE ix
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ;Check it chose the second M slot
    ld a, (iy+slotStruct.id)
    nop ; ASSERTION A==109


.data:
    db "MISSILE\nCOMMAND",0
    TC_END



    endmodule
