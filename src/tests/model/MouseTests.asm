    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Mouse

    MACRO TEST_MOUSE_OVER len, src, expected
        COPY_DATA len,src
        call Mouse.mouseOver
        ld b,expected
        nop ; ASSERTION A==B
        TC_END
    ENDM

;0 difference
UT_dragStart1:
    COPY_DATA dragStartLen, dragStartData
    ld a,1
    call Mouse.funcDragStart
    TEST_MEMORY_BYTE Mouse.dragXOffset,0
    TEST_MEMORY_BYTE Mouse.dragYOffset,0
    TC_END
;Positive difference
UT_dragStart2:
    COPY_DATA dragStartLen, dragStartData
    ld a,2
    call Mouse.funcDragStart
    TEST_MEMORY_BYTE Mouse.dragXOffset,10
    TEST_MEMORY_BYTE Mouse.dragYOffset,4
    TC_END
;Negative difference, set offsets to be 0 as -ve differences are not expected
UT_dragStart4:
    COPY_DATA dragStartLen, dragStartData
    ld a,3
    call Mouse.funcDragStart
    TEST_MEMORY_BYTE Mouse.dragXOffset,0
    TEST_MEMORY_BYTE Mouse.dragYOffset,0
    TC_END
dragStartData:
    db 5
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,200,100,0,16,0,0
    spriteItem 2,190,96,0,8,0,0
    spriteItem 3,201,102,0,30,0,0
    spriteItem 4,100,30,0,24,0,0
dragStartLen: equ $ - dragStartData

;Check x>255
UT_dragStart3:
    COPY_DATA dragStartLen3, dragStartData3
    ld a,1
    call Mouse.funcDragStart
    TEST_MEMORY_BYTE Mouse.dragXOffset,5
    TC_END
dragStartData3:
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,306,100,0,0,0,0
    spriteItem 1,301,100,0,16,0,0
dragStartLen3: equ $ - dragStartData3



UT_drag1:
    COPY_DATA dragLen, dragData
    ld a,5
    ld (Mouse.dragXOffset),a
    ld a,7
    ld (Mouse.dragYOffset),a

    ld a,1
    call Mouse.funcDrag
    TEST_MEMORY_WORD SpriteList.list+spriteItem+spriteItem.x,195
    TEST_MEMORY_BYTE SpriteList.list+spriteItem+spriteItem.y,93
    TC_END
dragData:
    db 5
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,0,0,16,0,0,0
dragLen: equ $ - dragData




;Only mouse sprite
UT_mouseOverNoSprites:
    TEST_MOUSE_OVER len0,data0,0
data0:
    db 1
    ; id, x, y, palette, pattern, gameId, flags
    db 0,160,0,0,128,0
len0: equ $ - data0


; One sprite mouse over
UT_mouseOver1:
    TEST_MOUSE_OVER len1,data1,42
data1:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,206,100,0,0,0,0
    spriteItem 42,200,94,0,16,0,0
len1: equ $ - data1


; One sprite, no collision
UT_mouseOver2:
    TEST_MOUSE_OVER len2,data2,0
data2
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,50,150,0,16,0,0
len2: equ $ - data2


;two sprites, one collision
UT_mouseOver3:
    TEST_MOUSE_OVER len3,data3,0
data3
    ; Count
    db 4
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,50,150,0,16,0,0
    spriteItem 2,195,106,0,0,0,0
len3: equ $ - data3

; One sprite x collision only
UT_mouseOver5:
    TEST_MOUSE_OVER len5,data5,0
data5:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,196,50,0,16,0,0
len5: equ $ - data5

; One sprite y collision only
UT_mouseOver6:
    TEST_MOUSE_OVER len6,data6,0
data6:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,200,100,0,0,0,0
    spriteItem 1,100,103,0,16,0,0
len6: equ $ - data6

; Collision where x>255
UT_mouseOver7:
    TEST_MOUSE_OVER len7,data7,5
data7:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,306,103,0,0,0,0
    spriteItem 5,296,100,0,16,0,0
len7: equ $ - data7

; Collision where x delta is 15
UT_mouseOver8:
    TEST_MOUSE_OVER len8,data8,8
data8:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,55,103,0,0,0,0
    spriteItem 8,40,100,0,16,0,0
len8: equ $ - data8

; Collision where x delta is 16 (no collision)
UT_mouseOver9:
    TEST_MOUSE_OVER len9,data9,0
data9:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,40,100,0,0,0,0
    spriteItem 9,56,103,0,16,0,0
len9: equ $ - data9

; Collision where x delta is -1
UT_mouseOver10:
    TEST_MOUSE_OVER len10,data10,0
data10:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,53,103,0,0,0,0
    spriteItem 10,54,100,0,16,0,0
len10: equ $ - data10

; Collision where y delta is -1 (no collision)
UT_mouseOver11:
    TEST_MOUSE_OVER len11,data11,0
data11:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,57,102,0,0,0,0
    spriteItem 9,55,103,0,16,0,0
len11: equ $ - data11

; Collision 0 xy delta
UT_mouseOver12:
    TEST_MOUSE_OVER len12,data12,42
data12:
    ; Count
    db 2
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,0,0,0,0,0,0
    spriteItem 42,0,0,0,16,0,0
len12: equ $ - data12



    endmodule