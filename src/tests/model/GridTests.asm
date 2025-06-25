    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Grid

UT_rowToPixel1:
    ld a,0
    call Grid.rowToPixel
    nop ; ASSERTION A == 0

    ld a,1
    call Grid.rowToPixel
    nop ; ASSERTION A == 24

    ld a,5
    call Grid.rowToPixel
    nop ; ASSERTION A == 120

    ld a,10
    call Grid.rowToPixel
    nop ; ASSERTION A == 240
    TC_END


UT_colToPixel1:
    ld a,0
    call Grid.colToPixel
    nop ; ASSERTION BC == 0

    ld a,1
    call Grid.colToPixel
    nop ; ASSERTION BC == 20

    ld a,5
    call Grid.colToPixel
    nop ; ASSERTION BC == 100

    ld a,15
    call Grid.colToPixel
    nop ; ASSERTION BC == 300
    TC_END



;Less than 10 tiles
UT_getMaxTilesPerRow1:
    ld a,0
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 0
    ld a,5
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 5
    ld a,9
    call Grid.getMaxTilesPerRow
    nop ; ASSERTION A == 9
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

UT_getTileStartColumn1:
    ld a,0
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN

    ld a,1
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 1
    
    ld a,2
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 1
    
    ld a,5
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 3

    ld a,6
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 3
    
    ld a,8
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 4

    ld a,9
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 5

    ld a,10
    call Grid.getTileStartColumn
    nop ; ASSERTION A == Grid.GRID_CENTER_COLUMN - 5

    TC_END

;
; [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10] [11] [12] [13] [14] [15]
;                                  ^ Center
UT_getColumnBounds1:

    ld a,0
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN 
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN

    ld a,1
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN 
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN

    ld a,2
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 1
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN

    ld a,8
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 4
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN + 3

    ld a,9
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 5
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN + 3

    TC_END

UT_getColumnBounds2:

    ld a,15
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 4
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN + 3

    ld a,27
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 5
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN + 3

    ld a,28
    call Grid.getColumnBounds
    nop ; ASSERTION B == Grid.GRID_CENTER_COLUMN - 5
    nop ; ASSERTION C == Grid.GRID_CENTER_COLUMN + 4

    TC_END

    endmodule
