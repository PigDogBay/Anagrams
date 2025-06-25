;-----------------------------------------------------------------------------------
; 
; Module: Grid 
; 
; Helper functions to layout the the tiles and slots in a grid
; 
; 
; 
;-----------------------------------------------------------------------------------

    module Grid


MAX_TILES_PER_ROW:          equ 10


;-----------------------------------------------------------------------------------
; 
; Function: getMaxTilesPerRow(uint8 tileCount) -> uint8
;
; Helper function to layout the tiles, works out how many tiles should fit
; on to each row, the idea is to fill the rows as equally as possible.
;
; < 10 tiles: 1 row max 10 tiles max (default)
; < 20 tiles: 2 rows 5 - 10 tiles max
; < 30 tiles: 3 rows, 7 - 10 tiles max
; < 40 tiles: 4 rows, 10 tiles max (default)
; 
; In: Total number of tiles to layout
; Out: A maximum number of tiles per row
; 
; Dirty A
; 
;-----------------------------------------------------------------------------------
getMaxTilesPerRow:
    ;If under 10 tiles show on one line
    cp MAX_TILES_PER_ROW
    jr c, .exit

    cp 20
    jr nc, .lessThan22
    ;2 rows with 6-10 tiles per row
    ; Divide by 2 (round up)
    inc a
    srl a
    ret

;For the 3 row case, only 3 cases so no need for complicated divide by 3
.lessThan22:
    cp 7*3+1
    jr nc, .lessThan25
    ld a,7
    ret
.lessThan25:
    cp 8*3+1
    jr nc, .lessThan28
    ld a,8
    ret
.lessThan28:
    cp 9*3+1
    jr nc, .exit
    ld a,9
    ret


.exit
    ;default value
    ld a,MAX_TILES_PER_ROW
    ret

;-----------------------------------------------------------------------------------
;
; Function: rowToPixel(uint8 row) -> uint8
;
; Convert row ato pixel co-ordinates
;
; In: A row
; Out: A pixel (y-coord) of the top of the row 
;
;-----------------------------------------------------------------------------------
rowToPixel:
    push bc

    ; Each row is 24 pixels high, so need to multiply row by 24
    ; y = row * 24 = 8(2r + r)
    ; x3
    ld b,a
    sla a
    add b
    ; x8
    sla a: sla a: sla a

    pop bc
    ret

;-----------------------------------------------------------------------------------
;
; Function: colToPixel(uint8 row) -> uint8
;
; Convert column to pixel co-ordinates
;
; In: A coloumn
; Out: BC pixel (x-coord) of the left hand side of the column 
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
colToPixel:
    ; Each column is 20 pixels, so need to multiply column by 20
    ; y = col * 20 = 4(4c + c)
    ;x5
    ld b,a
    sla a: sla a
    add b
    ;x4
    sla a: sla a
    ld c,a
    ld (ix + spriteItem.x),a
    ; Copy carry flag into x's high byte
    ld a,0
    adc a
    ld b,a
    ret

    endmodule
