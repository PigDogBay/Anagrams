;-----------------------------------------------------------------------------------
; Module GamePhases
;
; Handles the logic for each game phase
;
; Function: start()
; 
;-----------------------------------------------------------------------------------
    module GamePhases

PHASE_START     equ 0
PHASE_ROUND     equ 1
PHASE_WIN       equ 2

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

    ;Set up the game settings based on the chosen college
    call College.getCollegeStruct
    ld ix,hl
    ld hl,(ix + collegeStruct.startTime)
    ld (Time.yearStartTime),hl
    ld a,(ix + collegeStruct.timePerYear)
    ld (Time.roundDecrease),a
    
    ld a,(ix + collegeStruct.lifeLineCost1)
    ld (Lifelines.costTile),a
    ld a,(ix + collegeStruct.lifeLineCost2)
    ld (Lifelines.costSlot),a
    ld a,(ix + collegeStruct.lifeLineCost3)
    ld (Lifelines.costRand),a
    ld a,(ix + collegeStruct.lifeLineCost4)
    ld (Lifelines.costClue),a
    ld a,(ix + collegeStruct.rerollCost)
    ld (RoundVM.rerollInitialCost),a
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
    call Time.reset
    ;Lower start time to make each level harder
    call Time.decreaseStartTime
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
    ld hl, (Time.time)
    ;Is time 0?
    ld a,l
    or h
    ret

;-----------------------------------------------------------------------------------
; 
; Function: solvedExit() -> uint16 
;
; Updates the game variables at when leaving the solved state
;
; Out: B - Next game phase
; 
;-----------------------------------------------------------------------------------
solvedExit:
    call YearTerm.nextTerm
    or a
    ld b, PHASE_START
    ret nz
    
    call YearTerm.nextYear
    or a
    ld b, PHASE_ROUND
    ret nz
    
    ld b, PHASE_WIN
    ret

    endmodule
