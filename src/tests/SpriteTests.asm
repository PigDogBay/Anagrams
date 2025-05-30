    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Sprite

    MACRO COPY_DATA len, src
        ld bc, len
        ld de, sprite.count
        ld hl, src
        ldir
    ENDM

    MACRO TEST_MOUSE_OVER len, src, expected
        COPY_DATA len,src
        call sprite.mouseOver
        ld b,expected
        nop ; ASSERTION A==B
        TC_END
    ENDM

;Mid list
UT_find1:
    COPY_DATA findLen, findData
    ld a,3
    call sprite.funcFind
    ld de, sprite.list + spriteItem * 3
    nop ; ASSERTION HL == DE
    TC_END
;Start
UT_find2:
    COPY_DATA findLen, findData
    ld a,0
    call sprite.funcFind
    ld de, sprite.list
    nop ; ASSERTION HL == DE
    TC_END
;End
UT_find3:
    COPY_DATA findLen, findData
    ld a,4
    call sprite.funcFind
    ld de, sprite.list + spriteItem*4
    nop ; ASSERTION HL == DE
    TC_END
;Not found
UT_find4:
    COPY_DATA findLen, findData
    ld a,99
    call sprite.funcFind
    nop ; ASSERTION HL == 0
    TC_END
findData:
    db 5
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,160,0,128,0
    db 1,100,0,150,16
    db 2,20,0,10,8
    db 3,60,0,20,30
    db 4,100,0,30,24
findLen: equ $ - findData

;0 difference
UT_dragStart1:
    COPY_DATA dragStartLen, dragStartData
    ld a,1
    call sprite.funcDragStart
    TEST_MEMORY_BYTE sprite.dragXOffset,0
    TEST_MEMORY_BYTE sprite.dragYOffset,0
    TC_END
;Positive difference
UT_dragStart2:
    COPY_DATA dragStartLen, dragStartData
    ld a,2
    call sprite.funcDragStart
    TEST_MEMORY_BYTE sprite.dragXOffset,10
    TEST_MEMORY_BYTE sprite.dragYOffset,4
    TC_END
;Negative difference, set offsets to be 0 as -ve differences are not expected
UT_dragStart4:
    COPY_DATA dragStartLen, dragStartData
    ld a,3
    call sprite.funcDragStart
    TEST_MEMORY_BYTE sprite.dragXOffset,0
    TEST_MEMORY_BYTE sprite.dragYOffset,0
    TC_END
dragStartData:
    db 5
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,200,0,100,0
    db 1,200,0,100,16
    db 2,190,0,96,8
    db 3,201,0,102,30
    db 4,100,0,30,24
dragStartLen: equ $ - dragStartData

;Check x>255
UT_dragStart3:
    COPY_DATA dragStartLen3, dragStartData3
    ld a,1
    call sprite.funcDragStart
    TEST_MEMORY_BYTE sprite.dragXOffset,5
    TC_END
dragStartData3:
    db 2
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,50,1,100,0
    db 1,45,1,100,16
dragStartLen3: equ $ - dragStartData3



UT_drag1:
    COPY_DATA dragLen, dragData
    ld a,5
    ld (sprite.dragXOffset),a
    ld a,7
    ld (sprite.dragYOffset),a

    ld a,1
    call sprite.funcDrag
    TEST_MEMORY_WORD sprite.list+spriteItem+spriteItem.x,195
    TEST_MEMORY_BYTE sprite.list+spriteItem+spriteItem.y,93
    TC_END
dragData:
    db 5
    ; id, x (16 bit), y, pattern
    ; Mouse
    db 0,200,0,100,0
    db 1,0,0,0,16
dragLen: equ $ - dragData




;Only mouse sprite
UT_mouseOverNoSprites:
    TEST_MOUSE_OVER len0,data0,0
data0:
    db 1
    ; id, x (16 bit), y, pattern
    db 0,160,0,128,0
len0: equ $ - data0


; One sprite mouse over
UT_mouseOver1:
    TEST_MOUSE_OVER len1,data1,42
data1:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,206,0,100,0
    db 42,200,0,94,16
len1: equ $ - data1


; One sprite, no collision
UT_mouseOver2:
    TEST_MOUSE_OVER len2,data2,0
data2
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,50,0,150,16
len2: equ $ - data2


;two sprites, one collision
UT_mouseOver3:
    TEST_MOUSE_OVER len3,data3,0
data3
    ; Count
    db 4
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,50,0,150,16
    db 2,195,0,106,0
len3: equ $ - data3

; One sprite x collision only
UT_mouseOver5:
    TEST_MOUSE_OVER len5,data5,0
data5:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,196,0,50,16
len5: equ $ - data5

; One sprite y collision only
UT_mouseOver6:
    TEST_MOUSE_OVER len6,data6,0
data6:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,100,0,103,16
len6: equ $ - data6

; Collision where x>255
UT_mouseOver7:
    TEST_MOUSE_OVER len7,data7,5
data7:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,50,1,103,0
    db 5,40,1,100,16
len7: equ $ - data7

; Collision where x delta is 15
UT_mouseOver8:
    TEST_MOUSE_OVER len8,data8,8
data8:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,55,0,103,0
    db 8,40,0,100,16
len8: equ $ - data8

; Collision where x delta is 16 (no collision)
UT_mouseOver9:
    TEST_MOUSE_OVER len9,data9,0
data9:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,40,0,100,0
    db 9,56,0,103,16
len9: equ $ - data9

; Collision where x delta is -1
UT_mouseOver10:
    TEST_MOUSE_OVER len10,data10,0
data10:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,53,0,103,0
    db 10,54,0,100,16
len10: equ $ - data10

; Collision where y delta is -1 (no collision)
UT_mouseOver11:
    TEST_MOUSE_OVER len11,data11,0
data11:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,57,0,102,0
    db 9,55,0,103,16
len11: equ $ - data11

; Collision 0 xy delta
UT_mouseOver12:
    TEST_MOUSE_OVER len12,data12,42
data12:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,0,0,0,0
    db 42,0,0,0,16
len12: equ $ - data12



    endmodule