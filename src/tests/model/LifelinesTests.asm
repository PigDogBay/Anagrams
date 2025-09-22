     module TestSuite_Lifelines


setUp:
    call GameId.reset
    call Slot.removeAll
    ld hl,.data
    call Slot.createSlots

    call Tile.removeAll
    ld hl,.data
    call Tile.createTiles
    ret
.data:
    db "ACORN",0

    macro SLOT_TILE tileId, slotId
        ld b, GameId.TILE_ID + tileId
        ld C, GameId.SLOT_ID + slotId
        call Board.slotTile
    endm

;All tiles slotted
UT_filterByUnslottedTiles1:
    call setUp
    SLOT_TILE 1,1
    SLOT_TILE 2,2
    SLOT_TILE 3,3
    SLOT_TILE 4,4
    SLOT_TILE 5,5

    call Lifelines.filterByUnslottedTiles
    ld a, (List.count)
    nop ; ASSERTION A == 0
    TC_END

;4 slotted, 1 unslotted
UT_filterByUnslottedTiles2:
    call setUp
    SLOT_TILE 1,1
    SLOT_TILE 2,2
    ;SLOT_TILE 3,3
    SLOT_TILE 4,4
    SLOT_TILE 5,5

    call Lifelines.filterByUnslottedTiles
    ld a, (List.count)
    nop ; ASSERTION A == 1
    ld a, (List.list)
    and $0f ; Remove GameId's Tile flag
    nop ; ASSERTION A == 3
    TC_END

;3 slotted, 2 unslotted
UT_filterByUnslottedTiles3:
    call setUp
    SLOT_TILE 1,1
    ;SLOT_TILE 2,2
    SLOT_TILE 3,3
    SLOT_TILE 4,4
    ;SLOT_TILE 5,5

    call Lifelines.filterByUnslottedTiles
    ld a, (List.count)
    nop ; ASSERTION A == 2
    ld a, (List.list + 1)
    and $0f ; Remove GameId's Tile flag
    nop ; ASSERTION A == 5

    TC_END

;0 slotted, 5 unslotted
UT_filterByUnslottedTiles4:
    call setUp

    call Lifelines.filterByUnslottedTiles
    ld a, (List.count)
    nop ; ASSERTION A == 5
    TC_END



     endmodule
