    module Print

AT:                      EQU $16



;-----------------------------------------------------------------------------------
; 
; Function: setCursorPosition(uint16 str) 
; 
; Prints a string starting at the current position, 
; moves the cursor along to position after last printed char
;
; In: HL - pointer to null terminated string
; 
; Dirty A 
;
;-----------------------------------------------------------------------------------
printString:
    jr cursorNext




;-----------------------------------------------------------------------------------
; 
; Function: setCursorPosition(uint8 x, uint8 y) 
; 
; Prints a character at the current position, moves the cursor along
; In: A - char to print
; 
; Dirty A 
;
;-----------------------------------------------------------------------------------
printChar:
    jr cursorNext


;-----------------------------------------------------------------------------------
; 
; Function: setCursorPosition(uint8 x, uint8 y) 
; 
; In: D - X position
;     E - Y position 
; 
; Dirty A 
;
;-----------------------------------------------------------------------------------
setCursorPosition:
    ld a,d
    ld (cursorX),a
    ld a,e
    ld (cursorY),a
    ret


;-----------------------------------------------------------------------------------
; 
; Function: cursorNext()
; 
; Moves the cursor to the next print position
;
; Dirty 
;
;-----------------------------------------------------------------------------------
cursorNext:
    ret


cursorX:
    db 20
cursorY:
    db 16

    endmodule