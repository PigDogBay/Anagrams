;-----------------------------------------------------------------------------------
; Module College
;
; Handles the college logic
;
;
; Function: resetCollege() -> uint8
; Function: previousCollege() -> uint8
; Function: nextCollege() -> uint8
; Function: getGameSettings() -> uint16 *collegeStruct
; Function: getCollegeName() -> uint16
;
;-----------------------------------------------------------------------------------
    module College

;-----------------------------------------------------------------------------------
;
; Struct: collegeStruct 
;
; Specifies the game set up
;
;
;-----------------------------------------------------------------------------------
    struct @collegeStruct
name            word        ;Pointer to string
startTime       word        ;Start time in seconds
timePerYear     byte        ;How much to decrease the start time each year
lifeLineCost1   byte        ;Cost in seconds of life line 1..4
lifeLineCost2   byte        ;If 0, then exclude life line
lifeLineCost3   byte
lifeLineCost4   byte
rerollCost      byte
    ends

    
COLLEGE_COUNT: equ 11
CHRISTMAS_COLLEGE: equ 10

;-----------------------------------------------------------------------------------
; 
; Function: getCollege() -> uint8
;
; Getter for college value
;
; Out: A = 0 ..< COLLEGE_COUNT
; 
;-----------------------------------------------------------------------------------
getCollege:
    ld a,(college)
    ret
    
;-----------------------------------------------------------------------------------
; 
; Function: resetCollege() -> uint8
;
; Sets college value to 0
;
; Out: A = 0 
; 
;-----------------------------------------------------------------------------------
resetCollege:
    xor a
    ld (college),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: previousCollege() -> uint8
;
; Sets and returns previous college value, will wrap round to COLLLEGE_LEN-1
;
; Out: A = previous college value 
; 
;-----------------------------------------------------------------------------------
previousCollege:
    ld a,(college)
    or a
    jr nz, .noWrapAround
    ld a, COLLEGE_COUNT
.noWrapAround:
    dec a
    ld (college),a
    ret

;-----------------------------------------------------------------------------------
; 
; Function: nextCollege() -> uint8
;
; Sets and returns next college value, will wrap round to 0
;
; Out: A = next college value 
; 
;-----------------------------------------------------------------------------------
nextCollege:
    ld a,(college)
    inc a
    cp COLLEGE_COUNT
    jr nz, .noWrapAround
    xor a
.noWrapAround:
    ld (college),a
    ret


;-----------------------------------------------------------------------------------
; 
; Function: getCollegeStruct() -> uint16 *collegeStruct
;
; Getter for the the currently selected college's name and game settings
;
; Out: HL = pointer to the college settings (*collegeStruct)
;
; Dirty A, HL, B
; 
;-----------------------------------------------------------------------------------
getCollegeStruct:
    ld a,(college)
    ld hl, gameSettings
    or a
    ret z

    ld b,a
.moveToIndex:
    add hl, collegeStruct
    djnz .moveToIndex
    ret

;-----------------------------------------------------------------------------------
; 
; Function: getCollegeName() -> uint16
;
; Getter for college name
;
; Out: HL = college name
;
; Dirty A
; 
;-----------------------------------------------------------------------------------
getCollegeName:
    push bc
    call getCollegeStruct
    ld bc,(HL)
    ld hl,bc
    pop bc
    ret

collegeNameStr1: db "TEDDY HALL",0
collegeNameStr2: db "ST EASY PEASEYS",0
collegeNameStr3: db "FOOTLIGHTS",0
collegeNameStr4: db "ST HENRYS",0
collegeNameStr5: db "BAILEY HALL",0
collegeNameStr6: db "LADY HOLLY HALL",0
collegeNameStr7: db "HEART BRIDGE",0
collegeNameStr8: db "TRENT COLLEGE",0
collegeNameStr9: db "WINTERVILLE",0
collegeNameStr10: db "ST KAYLEIGH'S",0
collegeNameStr11: db "YULE UNIVERSITY",0

;College Settings
; Start time, time per year, life1, life2, life3, life4, reroll
gameSettings:
    collegeStruct collegeNameStr1, 400, 20, 12,  0,  5, 10, 25
    collegeStruct collegeNameStr2, 600, 25, 15, 20,  5, 10, 50
    collegeStruct collegeNameStr3, 300, 10, 10,  0,  0, 10, 20
    collegeStruct collegeNameStr4, 350, 15,  0, 12,  5,  0, 20
    collegeStruct collegeNameStr5, 250, 15, 12,  0,  5,  0, 20
    collegeStruct collegeNameStr6, 280, 15,  0, 20,  5, 10, 20
    collegeStruct collegeNameStr7, 350, 25, 20,  0, 10, 15, 25
    collegeStruct collegeNameStr8, 500, 50,  0, 25, 10, 15, 40 
    collegeStruct collegeNameStr9, 200,  5,  7,  12, 4,  8, 20 
    collegeStruct collegeNameStr10,450, 20,  0, 25,  0, 15, 50 
    collegeStruct collegeNameStr11,750, 25, 15, 20,  5, 10, 50

college:
    db 0

    endmodule
