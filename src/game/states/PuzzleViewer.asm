;-----------------------------------------------------------------------------------
; 
; State: PuzzlerViewer
; 
; This state is used for debugging, it steps through each puzzle to check it 
; correctly displays
;
; Initializes the game
; 
;-----------------------------------------------------------------------------------
    module GameState_PuzzleViewer


CATEGORY_TO_VIEW:   equ CAT_CHRISTMAS


@GS_PUZZLE_VIEWER: 
    stateStruct enter,update

puzzleIndex: db 0
            db 0

enter:
    ld hl,$0101
    call YearTerm.select
    L2_SET_IMAGE IMAGE_MICHAELMAS

    jp setUpPuzzle


setUpPuzzle:
    call Tilemap.clear
    call NextSprite.removeAll
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call Game.addMouseSpritePointer

    call Slot.removeAll
    call Tile.removeAll

    call GameId.reset

    ;Set up a random puzzle
    ld a,(puzzleIndex)
    ld b,BANK_PUZZLES_START + CATEGORY_TO_VIEW
    call Puzzles.copyPuzzleStrings

    call Puzzles.getPuzzle
    call Slot.createSlots

    call Puzzles.getPuzzle
    call Tile.createTiles
    call Tile.tilesToSprites
    call Slot.slotsToSprites

    call printTerm
    call printClue
    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    call YearTerm.nextTerm
    or a
    jp nz, setUpPuzzle

    
.incIndex:
    ;reset term
    ld hl,$0101
    call YearTerm.select
    ld a,(puzzleIndex)
    inc a
    cp a, 50
    jr nz, .continue:
    xor a

.continue:
    ld (puzzleIndex),a
    jp setUpPuzzle

printClue:
    ; Display Clue
    ld hl, Puzzles.clue
    ld e, 28
    ld b,%00000000
    call Print.printCentred
    ret



printTerm:
    ld de, Print.buffer
    ld hl,(puzzleIndex)
    ld a,1
    call ScoresConvert.ConvertToDecimal
    ex de,hl
    add hl,a
    ex de,hl

    ld hl, .delimiter
    call Print.bufferPrint

    call YearTerm.getShortTermName
    call Print.bufferPrint

    ;Print the buffer to the screen
    ld hl, Print.buffer
    ld e, 1
    ld b,%00000000
    call Print.printCentred
    ret
.delimiter:
    db ". ",0

    endmodule