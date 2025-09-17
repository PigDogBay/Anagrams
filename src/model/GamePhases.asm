;-----------------------------------------------------------------------------------
; Module GamePhases
;
; Handles the logic for each game phase
;
; Function: start()
; 
;-----------------------------------------------------------------------------------
    module GamePhases


;-----------------------------------------------------------------------------------
; 
; Function: start()
;
; Sets up the game variables, call at the very beginning of the game
;
; 
;-----------------------------------------------------------------------------------
start:
    ld hl,$0101
    call YearTerm.select
    call Money.resetMoney
    call Time.reset
    ret

;-----------------------------------------------------------------------------------
; 
; Function: roundStart()
;
; Updates the game variables at the beginning of the round
;
; Out: HL 
; 
;-----------------------------------------------------------------------------------
roundStart:
    ;Set up a random puzzle
    call Puzzles.newCategory
    call Puzzles.copyRandomPuzzle
    ret

;-----------------------------------------------------------------------------------
; 
; Function: playStart()
;
; Updates the game variables at the beginning of a new puzzle
; Here the slots and tiles are set up
;
; 
;-----------------------------------------------------------------------------------
playStart:
    call Slot.removeAll
    call Tile.removeAll

    call GameId.reset

    call Puzzles.getPuzzle
    call Slot.createSlots
    call Puzzles.jumbleLetters

    call Tile.createTiles
    call Tile.tilesToSprites
    call Slot.slotsToSprites
    ret

;-----------------------------------------------------------------------------------
; 
; Function: playUpdate() -> bool
;
; Ticks down the time, if time is 0 GAME OVER!
;
; Out: Z - if set, game over
; 
;-----------------------------------------------------------------------------------
playUpdate:
    call Time.onTick
    ld a,(Time.time)
    or a

    ret

;-----------------------------------------------------------------------------------
; 
; Function: solvedExit() -> uint16 
;
; Updates the game variables at when leaving the solved state
;
; Out: HL - next Game State
; 
;-----------------------------------------------------------------------------------
solvedExit:
    call YearTerm.nextTerm
    ld hl, GS_START
    or a
    ret nz
    
    call YearTerm.nextYear
    ld hl, GS_ROUND
    or a
    ret nz
    
    //TODO GS_GAME_COMPLETED, for now go back to level 1
    ld hl,$0101
    call YearTerm.select
    ld hl, GS_ROUND

    ret

    endmodule
