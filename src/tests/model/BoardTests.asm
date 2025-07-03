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
    call GameId.reset
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"R"
    TILE_ID_AT 3
    ld (iy + slotStruct.tileId),a
    call Board.isSlotSolved
    nop ; ASSERTION A==1

    TC_END
.data:
    db "ACORN\nELECTRON",0


;Case 2: wrong tile slotted
UT_isSlotSolved5:
    call Tile.removeAll
    call GameId.reset
    ld hl,.data
    call Tile.createTiles


    ld iy, Slot.slotList
    ld (iy + slotStruct.id),10
    ld (iy + slotStruct.letter),"N"
    ;Matching tile is at index 4
    TILE_ID_AT 6
    ld (iy + slotStruct.tileId),a
    call Board.isSlotSolved
    nop ; ASSERTION A==0

    TC_END
.data:
    db "ACORN\nELECTRON",0


;non-existant tile slotted
UT_isSlotSolved6:
    EXCEPTIONS_CLEAR
    call Tile.removeAll
    call GameId.reset
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


;Manually fill slots with tiles
UT_isSolved1:
    call Tile.removeAll
    call Slot.removeAll
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
    ld hl,.data
    call Tile.createTiles

    ld ix, Tile.tileList
    ld iy, Slot.slotList

    ld b,10
.next:
    ;next slot
    ld de,slotStruct
    add iy,de

    ld a, (iy+slotStruct.id)
    or a
    ;skip white space
    jr z, .next


    ; place tile
    ld a,(ix+tileStruct.id)
    ld (iy+slotStruct.tileId),a
    ;next tile
    ld de,tileStruct
    add ix,de
    djnz .next

    call Board.isSolved
    nop ; ASSERTION A == 1
.data:
    db "ZX\nSPECTRUM",0
    TC_END

;Use Board.findEmptyMatchingSlot to slot each tile
UT_isSolved2:
    call Tile.removeAll
    call Slot.removeAll
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
    ld hl,.random
    call Tile.createTiles


    FIRST_TILE ix
    ld b,10
.next:
    push bc
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ;Board should not be solved yet
    push iy
    call Board.isSolved
    pop iy
    pop bc
    nop ; ASSERTION A == 0

    ; place tile
    ld a,(ix+tileStruct.id)
    ld (iy+slotStruct.tileId),a

    NEXT_TILE ix
    djnz .next

    call Board.isSolved
    nop ; ASSERTION A == 1
.data:
    db "ZX\nSPECTRUM",0
.random:
    db "XC\nZMREUPST",0
    TC_END






    ;add some slots
    ;IX data tile sprite
    ;IY data slot sprite
    ;call Slot.snapTileToSlot
    ;check tiles XY
    ;check Slot.tileId
UT_snapTileToSlot1:
    call Slot.removeAll
    call GameId.reset
    ld hl,.data
    call Slot.createSlots

    ;Set up sprite with correct slot ID, 
    ; C is at index[2], [\n][A][C]
    SLOT_ID_AT 2
    ld (.slotSprite + spriteItem.gameId),a
    
    ld ix, .tileSprite
    ld iy, .slotSprite
    call Board.snapTileToSlot

    TEST_MEMORY_WORD .tileSprite + spriteItem.x,101
    TEST_MEMORY_BYTE .tileSprite + spriteItem.y,81
    SLOT_AT iy,2
    ld a,(iy+slotStruct.tileId)
    nop ;ASSERTION A == 42

    TC_END
.data:
    db "ACORN",0
.tileSprite:
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,160,128,0,0,42,0
;gameId = 'C' slot
.slotSprite:
    spriteItem 1,100,80,0,0,101,0


    ;Null Pointer test - IY has invalid game ID (slot ID)
    ;For now function just exits when it gets the null pointer
UT_snapTileToSlot2:
    EXCEPTIONS_CLEAR
    call Slot.removeAll
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    ld ix, .tileSprite
    ld iy, .slotSprite
    call Board.snapTileToSlot
    CHECK_NULL_POINTER_CALLED

    TC_END
.data:
    db "ACORN",0
.tileSprite:
    spriteItem 0,160,128,0,0,42,0
.slotSprite:
    ;12 should not be a valid slot ID
    spriteItem 1,100,80,0,0,12,0


UT_findEmptyMatchingSlot1:
    call Tile.removeAll
    call Slot.removeAll
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
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
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
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
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
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
    
    call GameId.reset
    ld hl,.data
    call Slot.createSlots
    
    ld hl,.data
    call Tile.createTiles

    ;Third M (index 10)
    TILE_AT ix, 10
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ;Check it chose the first M slot
    SLOT_ID_AT 1
    ld b,a
    ld a, (iy+slotStruct.id)
    nop ; ASSERTION A==B

    ;Place tile
    ld a,(ix+tileStruct.id)
    ld (iy+slotStruct.tileId),a


    ;First M tile
    FIRST_TILE ix
    call Board.findEmptyMatchingSlot
    nop ; ASSERTION A!=0

    ;Check it chose the second M slot
    SLOT_ID_AT 11
    ld b,a
    ld a, (iy+slotStruct.id)
    nop ; ASSERTION A==B


.data:
    db "MISSILE\nCOMMAND",0
    TC_END



    endmodule
