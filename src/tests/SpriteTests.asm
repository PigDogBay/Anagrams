    ; A unit testcase needs to start with "UT_" (upper case letters).
    ; DeZog will collect all these labels and offer them for execution.
    module TestSuite_Sprite


UT_mouseOverNoSprites:
    ;Copy test data
    ld bc,len0
    ld de, sprite.count
    ld hl, data0
    ldir

    call sprite.mouseOver ; ASSERT A==0
    TC_END

UT_mouseOver1:
    ;Copy test data
    ld bc,len1
    ld de, sprite.count
    ld hl, data1
    ldir

    call sprite.mouseOver ; ASSERT A==1
    TC_END


UT_mouseOver3:
    ;Copy test data
    ld bc,len3
    ld de, sprite.count
    ld hl, data3
    ldir

    call sprite.mouseOver ; ASSERT A==2
    TC_END

UT_mouseOver2:
    ;Copy test data
    ld bc,len2
    ld de, sprite.count
    ld hl, data2
    ldir

    call sprite.mouseOver ; ASSERT A==0
    TC_END




;Only mouse sprite
data0:
    db 1
    ; id, x (16 bit), y, pattern
    db 0,160,0,128,0
len0: equ $ - data0

; One sprite mouse over
data1:
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,206,0,94,16
len1: equ $ - data1

; One sprite, no collision
data2
    ; Count
    db 2
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,50,0,150,16
len2: equ $ - data2

;two sprites, one collision
data3
    ; Count
    db 4
    ; id, x (16 bit), y, pattern
    db 0,200,0,100,0
    db 1,50,0,150,16
    db 2,195,0,106,0
len3: equ $ - data3

    endmodule