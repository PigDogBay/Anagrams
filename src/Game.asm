    module game

init:
    ld a,30
    call NextSprite.load
    call SpriteList.removeAll
    ; First sprite always the mouse pointer so that it is on top
    call addMouseSpritePointer
    ld hl,anagram
    call Tile.wordToSprites
    ret

run:
    call updateMouse
    

    ;Check left mouse button (bit 1, 0 - pressed)
    ld a,(MouseDriver.buttons)
    ld b,0
    bit 1,a
    jr nz,.buttonPressed
    ld b,1
.buttonPressed
    ld a,b
    ld (SpriteList.list + spriteItem.pattern),a

    ld hl, SpriteList.count
    ld b,(hl)
    inc hl
.updateSprites:
    call NextSprite.update
    djnz .updateSprites

    BORDER 0
    call graphics.waitRaster
    ; Set border to blue, size of border indicates how much time is spent updating the game
    BORDER 1
    jr run
    ret


;-----------------------------------------------------------------------------------
;
; Function updateMouse
;
; Updates the mouse x,y position and state
; Any dragged sprites will be updated
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
    ; Store A for later use, IX is kept clean
    ld (spriteId),a

    ; Update the mouse pointer state
    ; In A - spriteID or 0 if not over a sprite
    call MouseDriver.updateState

    ; Check latest mouse state
    ld a, (MouseDriver.state)
    cp MouseDriver.STATE_DRAG_START
    jr nz, .checkDrag

    ; DRAG_START
    ;bring the sprite to the front
    ;In: HL points to spriteItem and will be swapped with the front most sprite
    ;Out: HL will now point to the front most sprite
    ld hl,ix
    call SpriteList.bringToFront
    ; Store spriteItem ptr
    ld (dragSpriteItem),hl
    ; In: IX pointer to spriteItem
    ld ix,hl
    call Mouse.dragStart
    jr .exit

.checkDrag
    cp MouseDriver.STATE_DRAG
    jr nz,.exit

    ; DRAG update, in IX - ptr to spriteItem of dragged sprite
    ld ix,(dragSpriteItem)
    call Mouse.dragSprite
    call Tile.boundsCheck
    jr nz, .exit
    ; Tile was out of bounds
    ; Need to tell mouse state machine
    call MouseDriver.dragOutOfBounds

.exit:
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



spriteId:               db 0
dragSpriteItem:         dw 0

anagram:
    db "ACORNELECTRON",0
    endmodule