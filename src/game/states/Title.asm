;-----------------------------------------------------------------------------------
; 
; State: Title
; 
; Shows title screen
; 
;-----------------------------------------------------------------------------------

    module GameState_Title

@GS_TITLE: 
    stateStruct enter,update


enter:
    call NextSprite.removeAll
    call Graphics.titleScreen

    ld bc, spriteLen
    ld de, SpriteList.count
    ld hl, spriteData
    ldir

    ld ix, motionData
    ld a, 10
    call MoveSprites.start
    call MoveSprites.initAllXY

    ret

update:
    ;wait for use to click mouse button
    call Game.updateMouseNoSprite
    cp MouseDriver.STATE_BACKGROUND_CLICKED
    jr z, .mousePressed
    call Game.updateSprites
    ret

.mousePressed:
    ld hl, GS_LEVEL_SELECT
    call GameStateMachine.change
    ret

titleText:
    db "THE\nSCHOLAR",0

spriteData:
    db 21
    ; id, x, y, palette, pattern, gameId, flags
    ; Mouse
    spriteItem 0,160,128,0,0,0,0

    ;Tile sprites
    spriteItem 1,180,170,0,'T'-Tile.ASCII_PATTERN_OFFSET,1,0
    spriteItem 2,120,195,0,'H'-Tile.ASCII_PATTERN_OFFSET,2,0
    spriteItem 3,180,195,0,'E'-Tile.ASCII_PATTERN_OFFSET,3,0
    spriteItem 4,201,168,0,'S'-Tile.ASCII_PATTERN_OFFSET,4,0
    spriteItem 5,100,177,0,'C'-Tile.ASCII_PATTERN_OFFSET,5,0
    spriteItem 6,219,183,0,'H'-Tile.ASCII_PATTERN_OFFSET,6,0
    spriteItem 7,140,195,0,'O'-Tile.ASCII_PATTERN_OFFSET,7,0
    spriteItem 8,160,195,0,'L'-Tile.ASCII_PATTERN_OFFSET,8,0
    spriteItem 9,140,170,0,'A'-Tile.ASCII_PATTERN_OFFSET,9,0
    spriteItem 10,160,170,0,'R'-Tile.ASCII_PATTERN_OFFSET,10,0

    ;Slots
    spriteItem 11,140,48,0,Slot.SLOT_SPRITE_PATTERN,11,0
    spriteItem 12,160,48,0,Slot.SLOT_SPRITE_PATTERN,12,0
    spriteItem 13,180,48,0,Slot.SLOT_SPRITE_PATTERN,13,0
    spriteItem 14,100,72,0,Slot.SLOT_SPRITE_PATTERN,14,0
    spriteItem 15,120,72,0,Slot.SLOT_SPRITE_PATTERN,15,0
    spriteItem 16,140,72,0,Slot.SLOT_SPRITE_PATTERN,16,0
    spriteItem 17,160,72,0,Slot.SLOT_SPRITE_PATTERN,17,0
    spriteItem 18,180,72,0,Slot.SLOT_SPRITE_PATTERN,18,0
    spriteItem 19,200,72,0,Slot.SLOT_SPRITE_PATTERN,19,0
    spriteItem 20,220,72,0,Slot.SLOT_SPRITE_PATTERN,20,0


spriteLen: equ $ - spriteData

motionData:
    ; gameId, stepX, countX, stepY, countY, delay 
    motionStruct 1, 1, 141, 1, 49, 90 
    motionStruct 2, 1, 161, 1, 49, 60 
    motionStruct 3, 1, 181, 1, 49, 70 
    motionStruct 4, 1, 101, 1, 73, 80 
    motionStruct 5, 1, 121, 1, 73, 10 
    motionStruct 6, 1, 141, 1, 73, 100 
    motionStruct 7, 1, 161, 1, 73, 40 
    motionStruct 8, 1, 181, 1, 73, 20 
    motionStruct 9, 1, 201, 1, 73, 50 
    motionStruct 10, 1, 221, 1, 73, 30 

    endmodule