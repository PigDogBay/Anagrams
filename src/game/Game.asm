    module Game

;-----------------------------------------------------------------------------------
; 
; Game Constants
;
;-----------------------------------------------------------------------------------

LIFELINE_FLASH_DURATION        equ 200



;-----------------------------------------------------------------------------------
; 
; Function: run()
;
; Game loop
;
;-----------------------------------------------------------------------------------
run:
    IFDEF BATTLEGROUND
        ld hl, GS_BATTLEGROUND
    ELSE
        ld hl, GS_TITLE
    ENDIF
    call GameStateMachine.change

.loop:
    call Timing.onTick
    call NextDAW.update
    IFDEF DEBUG_MODE
        call Keyboard.update
    ENDIF
    call Joystick.update
    call GameStateMachine.update
    call Animator.update
    
    ;BORDER 0
    call Graphics.waitRaster
    ; Set border to blue, size of border indicates how much time is spent updating the game
    ;BORDER 5

    jr .loop


;-----------------------------------------------------------------------------------
; 
; Function: printInstruction(uint16 str, uint8 yPos) 
; 
; Print an instruction string centred, at the specified yPos
; 
; In: HL pointer to string
;     E yPos 0-31
; 
;-----------------------------------------------------------------------------------
printInstruction:
    ; Centre clue
    call String.len
    neg
    add 40
    sra a
    ld d, a
    call Print.setCursorPosition
    ld b,Tilemap.PURPLE
    call Print.printString
    ret

;-----------------------------------------------------------------------------------
;
; Function updateSprites
; Update the Next sprite engine with the latest data for every sprite
;
;-----------------------------------------------------------------------------------
updateSprites:
    ld hl, SpriteList.count
    ld a,(hl)
    or a
    ret z
    ld b,a
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
;      C - Game ID or 0 (cache this when tracking a sprites mouse interection)
;      IX - spriteItem if over a sprite (do NOT cache this as sprites can be re-ordered)
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
    ; In C - gameId or 0
    ld c,a
    or a
    jr z, .noSpriteOver
    ld a,(ix+spriteItem.flags)
    ld c,(ix+spriteItem.gameId)
.noSpriteOver:    
    call MouseDriver.updateState

    ld a, (MouseDriver.state)
    ret

;-----------------------------------------------------------------------------------
;
; Function updateMouseNoSprite()
;
; Updates the mouse x,y position and state
;
; Out: A - current mouse state
;
;-----------------------------------------------------------------------------------
updateMouseNoSprite:
    ; Get the latest mouse X,Y and buttons
    call MouseDriver.update
    ld hl,(MouseDriver.mouseX)
    ld a,(MouseDriver.mouseY)
    ; Store X,Y in mouse's spriteItem
    ld (SpriteList.list + spriteItem.x),hl
    ld (SpriteList.list + spriteItem.y),a
    ;A=0 no sprites, C id = 0
    xor a
    ld c,a
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
    ; id, x, y, palette, pattern, gameId, flags
    spriteItem 0,0,0,0,SPRITE_VISIBILITY_MASK,0,0

    endmodule