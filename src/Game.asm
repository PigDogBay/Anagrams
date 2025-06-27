    module Game

init:
    ld a,30
    call NextSprite.load
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call addMouseSpritePointer

    call Slot.removeAll
    call Tile.removeAll
    ld hl,anagram
    ;TODO, start game ID at 16 for tiles and slots, need better management of this
    ld c, 16
    call Slot.createSlots
    ld hl,anagram
    ; Randomize letters
    call String.shuffle
    call Tile.createTiles
    call Tile.tilesToSprites
    call Slot.slotsToSprites
    ret

run:
    call updateMouse
    call MouseListener.update
    call updateSprites

    BORDER 5
    call Graphics.waitRaster
    ; Set border to blue, size of border indicates how much time is spent updating the game
    BORDER 1

    jr run


;-----------------------------------------------------------------------------------
;
; Function updateSprites
; Update the Next sprite engine with the latest data for every sprite
;
;-----------------------------------------------------------------------------------
updateSprites:
    ld hl, SpriteList.count
    ld b,(hl)
    inc hl
.next:
    call NextSprite.update
    djnz .next
    ret


;-----------------------------------------------------------------------------------
;
; Function updateMouse
;
; Updates the mouse x,y position and state
; Any dragged sprites will be updated
;
; Out: A - current mouse state
;
;-----------------------------------------------------------------------------------
updateMouse:
    ; Get the latest mouse X,Y and buttons
    call MouseDriver.update
    ld hl,(MouseDriver.mouseX)
    ld a,(MouseDriver.mouseY)
    ; Store X,Y in mouse's spriteItem
    ld (SpriteList.list + spriteItem.x),hl
    ld (SpriteList.list + spriteItem.y),a

    ;Check if the pointer is over a sprite
    ; A - sprite ID and IX - spriteItem if over a sprite
    ; A = 0 not over a sprite
    call Mouse.mouseOver

    ; Update the mouse pointer state
    ; In A - interaction flags, or 0 if not over a sprite
    or a
    jr z, .noSpriteOver
    ld a,(ix+spriteItem.flags)
.noSpriteOver:    
    call MouseDriver.updateState

    ld a, (MouseDriver.state)
    ret



;-----------------------------------------------------------------------------------
;
; addMouseSpritePointer
;
; Note the sprite pointer must be the first sprite so that it appears on top
; of the other sprites
;
; Dirty HL
;
;-----------------------------------------------------------------------------------
addMouseSpritePointer:
    ld hl, pointerSpriteItem
    call SpriteList.addSprite
    ret
pointerSpriteItem:
    spriteItem 0,0,0,0,0,0



anagram:
    db "THE ACE\nOF SPADES",0
;     db "BANG",0
;     db "THE DOG",0
;     db "ONE FLEW\nOVER THE\nCUCKOOS\nNEST",0
;     db "THE LORD\nOF THE\nRINGS THE\nFELLOWSHIP\nOF THE RING",0
    endmodule