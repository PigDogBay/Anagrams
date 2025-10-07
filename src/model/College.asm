;-----------------------------------------------------------------------------------
; Module College
;
; Handles the college logic
;
;
; Function: getCategory() -> uint8
; Function: categoryToString(uint8 cat) -> uint16
; Function: resetCollege() -> uint8
; Function: previousCollege() -> uint8
; Function: nextCollege() -> uint8
; Function: getCollegeName() -> uint16
;
;-----------------------------------------------------------------------------------
    module College

COLLEGE_COUNT: equ 10

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
    push de
    ld a,(college)
    ld hl, collegeNameJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    pop de
    ret


collegeNameJumpTable:
    dw collegeNameStr1
    dw collegeNameStr2
    dw collegeNameStr3
    dw collegeNameStr4
    dw collegeNameStr5
    dw collegeNameStr6
    dw collegeNameStr7
    dw collegeNameStr8
    dw collegeNameStr9
    dw collegeNameStr10

collegeNameStr1: db "TEDDY HALL",0
collegeNameStr2: db "MOR-DE-LEN COLLEGE",0
collegeNameStr3: db "FOOTLIGHTS",0
collegeNameStr4: db "ST HENRYS",0
collegeNameStr5: db "BAILEY HALL",0
collegeNameStr6: db "LADY HOLLY HALL",0
collegeNameStr7: db "HERTBRIDGE COLLEGE",0
collegeNameStr8: db "RADNOR COLLEGE",0
collegeNameStr9: db "WINTERVILLE",0
collegeNameStr10: db "ST KAYLEIGH'S HALL",0

college:
    db 0

    endmodule
