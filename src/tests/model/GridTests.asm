    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Grid

;Less than 10 tiles
UT_getMaxTilesPerRow1:
    ld a,0
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == Grid.MAX_TILES_PER_ROW
    ld a,5
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == Grid.MAX_TILES_PER_ROW
    ld a,9
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == Grid.MAX_TILES_PER_ROW
    TC_END

;Less than 10 - 19 tiles
UT_getMaxTilesPerRow2:
    ld a,10
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 5
    ld a,15
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 8
    ld a,19
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 10
    TC_END

;20-30
UT_getMaxTilesPerRow3:
    ld a,20
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 7
    ld a,22
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 8
    ld a,25
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 9
    ld a,28
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 10
    TC_END

;Over 30
UT_getMaxTilesPerRow4:
    ld a,30
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == Grid.MAX_TILES_PER_ROW
    ld a,40
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == Grid.MAX_TILES_PER_ROW
    TC_END

    endmodule
