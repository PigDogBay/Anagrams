;-----------------------------------------------------------------------------------
;
; Behaviour Test: Solving
;
; Create slots, tiles, place tiles in the slots and then check if solved
;
;-----------------------------------------------------------------------------------
    module TestSuite_Solving

UT_solving1:
    ;Create slots and tiles
    call Slot.removeAll
    call Tile.removeAll
    ld hl,anagram
    ld c, 16
    call Slot.createSlots
    ld hl,anagram
    call Tile.createTiles

    ;Create sprite data
    call Tile.tilesToSprites
    call Slot.slotsToSprites

    ;TODO - need mouse action simulator
    ; SpriteList - needs code to find sprite based on ID
    ;Find slot-tile sprites and drag the tile to the slot



    TC_END
anagram:
    db "ZX\nSPECTRUM",0
    ;Padding to stop debugger watchpoint being hit, 
    ;String.lenToChar scans past the string hunting for \n
    ;and strays into Stack territory
    ;TODO lenUpToChar should have a counter parameter
    block 256


    endmodule
