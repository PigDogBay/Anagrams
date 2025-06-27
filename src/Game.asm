    module Game

mouseStateJumpTable:
    dw stateMouseReady
    dw stateMouseHover
    dw stateMouseHoverEnd
    dw stateMousePressed
    dw stateMouseClicked
    dw stateMouseDragStart
    dw stateMouseDrag
    dw stateMouseDragOutOfBounds
    dw stateMouseDragEnd

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
    call mouseStateHandler
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
    ; Store A for later use, IX is kept clean
    ld (spriteId),a

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
; Function: mouseStateHandler
;
; Updates the game based on the current mouse state 
; In - A current mouse state
;    - IX pointer to sprite that mouse is over
;-----------------------------------------------------------------------------------
mouseStateHandler:
    ld hl, mouseStateJumpTable
    ; Add twice, as table is two bytes per entry
    add hl,a
    add hl,a
    ; get jump entry
    ld de,(hl)
    ld hl,de
    jp hl

stateMouseReady:
    ; Do nothing
    ret
stateMouseHover:
    ; Do nothing
    ret
stateMouseHoverEnd:
    ; Do nothing
    ret
stateMousePressed:
    ; Do nothing
    ret
stateMouseClicked:
    ; Do nothing
    ret

stateMouseDragStart:
    ;bring the sprite to the front
    ;bringToFront In: HL points to spriteItem and will be swapped with the front most sprite
    ;bringToFrontOut: HL will now point to the front most sprite
    call SpriteList.bringToFront
    call Mouse.dragStart

    ;Update mouse pointer pattern
    ld a,1
    ld (SpriteList.list + spriteItem.pattern),a

    ret

stateMouseDrag:
    ; DRAG update, dragged sprite is at index[1]
    ld ix,SpriteList.list + spriteItem
    call Mouse.dragSprite
    call Tile.boundsCheck
    ret nz
    ; Tile was out of bounds
    ; Need to tell mouse state machine
    call MouseDriver.dragOutOfBounds
    ret

stateMouseDragOutOfBounds:
    ;Update mouse pointer pattern
    ld a,0
    ld (SpriteList.list + spriteItem.pattern),a
    ret

stateMouseDragEnd:
    ;Update mouse pointer pattern
    ld a,0
    ld (SpriteList.list + spriteItem.pattern),a
    
    ;Out:   A - 0 if not over slot
    ;       IX - tile sprite
    ;       IY - slot sprite
    call Board.isSelectedTileOverSlot
    or a
    ret z
    
    ;if slot is occupied bounce tile downwards
    call Board.placeTile
    or a
    jr nz, .slotOccuppied
    call Board.snapTileToSlot
    ret
.slotOccuppied:
    call Board.bounceTile
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

anagram:
    db "THE ACE\nOF SPADES",0
;     db "BANG",0
;     db "THE DOG",0
;     db "ONE FLEW\nOVER THE\nCUCKOOS\nNEST",0
;     db "THE LORD\nOF THE\nRINGS THE\nFELLOWSHIP\nOF THE RING",0
    endmodule