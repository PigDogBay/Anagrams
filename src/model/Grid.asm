    module Grid

;-----------------------------------------------------------------------------------
;
; Function: rowColumnToPixel(uint16 ptrSprite)
;
; Convert row and column to pixel co-ordinates and store then in the
; spriteItem struct.
;
; In: IX - pointer to spriteItem struct
; 
; Dirty A
;
;-----------------------------------------------------------------------------------
rowColumnToPixel:
    push bc

    ; Each row is 24 pixels high, so need to multiply row by 24
    ; y = row * 24 = 8(2r + r)
    ld a,(row)
    ; x3
    ld b,a
    sla a
    add b
    ; x8
    
    sla a: sla a: sla a
    ld (ix + spriteItem.y),a

    ; Each column is 20 pixels, so need to multiply column by 20
    ; y = col * 20 = 4(4c + c)
    ld a,(column)
    ;x5
    ld b,a
    sla a: sla a
    add b
    ;x4
    sla a: sla a
    ld (ix + spriteItem.x),a
    ; Copy carry flag into x's high byte
    ld a,0
    adc a
    ld (ix + spriteItem.x + 1),a
 
    pop bc
    ret

row:
    db 0
column:
    db 0

    endmodule
