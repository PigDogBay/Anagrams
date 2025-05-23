    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Sprite


UT_mouseOverNoSprites:
    ;Copy test data
    ld bc,len0
    ld de, sprite.count
    ld hl, data0
    ldir

    call sprite.mouseOver
    nop ;ASSERTION A==0
    TC_END
;Only mouse sprite
data0:
    db 1
    ; id, x (16 bit), y, pattern
    db 0,160,0,128,0
len0: equ $ - data0


; One sprite mouse over
UT_mouseOver1:
    ;Copy test data
    ld bc,len1
    ld de, sprite.count
    ld hl, data1
    ldir

    call sprite.mouseOver 
    nop ; ASSERTION A==42
    TC_END
data1:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,206,0,100,0
    db 42,200,0,94,16
len1: equ $ - data1


; One sprite, no collision
UT_mouseOver3:
    ;Copy test data
    ld bc,len3
    ld de, sprite.count
    ld hl, data3
    ldir

    call sprite.mouseOver
    nop ;ASSERTION A==0

    TC_END
data2
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,50,0,150,16
len2: equ $ - data2



;two sprites, one collision
UT_mouseOver2:
    ;Copy test data
    ld bc,len2
    ld de, sprite.count
    ld hl, data2
    ldir

    call sprite.mouseOver
    nop ;ASSERTION A==0

    TC_END
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
    ;Copy test data
    ld bc,len5
    ld de, sprite.count
    ld hl, data5
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==0
    TC_END
data5:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,196,0,50,16
len5: equ $ - data5

; One sprite y collision only
UT_mouseOver6:
    ;Copy test data
    ld bc,len6
    ld de, sprite.count
    ld hl, data6
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==0
    TC_END
data6:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,100,0,103,16
len6: equ $ - data6

; Collision where x>255
UT_mouseOver7:
    ;Copy test data
    ld bc,len7
    ld de, sprite.count
    ld hl, data7
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==5
    TC_END
data7:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,50,1,103,0
    db 5,40,1,100,16
len7: equ $ - data7

; Collision where x delta is 15
UT_mouseOver8:
    ;Copy test data
    ld bc,len8
    ld de, sprite.count
    ld hl, data8
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==8
    TC_END
data8:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,55,0,103,0
    db 8,40,0,100,16
len8: equ $ - data8

; Collision where x delta is 16 (no collision)
UT_mouseOver9:
    ;Copy test data
    ld bc,len9
    ld de, sprite.count
    ld hl, data9
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==0
    TC_END
data9:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,40,0,100,0
    db 9,56,0,103,16
len9: equ $ - data9

; Collision where x delta is -1
UT_mouseOver10:
    ;Copy test data
    ld bc,len10
    ld de, sprite.count
    ld hl, data10
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==0
    TC_END
data10:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,53,0,103,0
    db 10,54,0,100,16
len10: equ $ - data10

; Collision where y delta is -1 (no collision)
UT_mouseOver11:
    ;Copy test data
    ld bc,len11
    ld de, sprite.count
    ld hl, data11
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==0
    TC_END
data11:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,57,0,102,0
    db 9,55,0,103,16
len11: equ $ - data11

; Collision 0 xy delta
UT_mouseOver12:
    ;Copy test data
    ld bc,len12
    ld de, sprite.count
    ld hl, data12
    ldir

    call sprite.mouseOver 
    nop ;ASSERTION A==42
    TC_END
data12:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,0,0,0,0
    db 42,0,0,0,16
len12: equ $ - data12



    endmodule