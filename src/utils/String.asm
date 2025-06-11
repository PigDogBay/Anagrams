;-----------------------------------------------------------------------------------
;
; Module: String
;
; Strings are null terminated, each character is a single byte
;
; Functions: 
;    len(uint16 ptr) -> uint8
;    shuffle(uint16 ptr)
; 
;-----------------------------------------------------------------------------------

    module String


;-----------------------------------------------------------------------------------
;
; Function: len(uint16 ptr) -> uint8
;
; Calculates the length of a String upto 253 bytes, the length excludes 0 terminator
; 
; In:  HL pointer to the string
; Out: A length
;      A = 255 string is longer than 255 bytes
;
; Dirty: A
;-----------------------------------------------------------------------------------

len:
    push hl
    push bc
    ld a,0
    ; Search for a max length of 255 chars
    ld bc,0x00ff
    cpir

    or c
    ld a,255
    jr z, .terminatorNotFound


    ; len = 255 - 1 - remaining count
    ; -1 for the \0 terminator
    ld a,254
    sub c

.terminatorNotFound:
    pop bc
    pop hl

    ret


;-----------------------------------------------------------------------------------
;
; Function: swap(uint16 ptr, uint8 i, uint8 j)
;
; Swap items at indices i and j in the String pointed to by HL
; 
;
; In:  HL pointer to the string
;      A - i, B - j     
;
; Dirty: A
;-----------------------------------------------------------------------------------
swap:
    push bc
    push de
    push hl

    ld de, hl
    add hl, a  ; hl [i]
    ex de,hl   ; de [i], hl - ptr 
    ld a,b
    add hl, a  ; de [i], hl [j]
    ld b,(hl)  ;  b = [j]
    ld a,(de)
    ld (hl),a
    ld a,b
    ld (de),a

    pop hl
    pop de
    pop bc
    ret




;-----------------------------------------------------------------------------------
;
; Function: shuffle(uint16 ptr)
;
; Knuth Shuffle (Fisher-Yates)
; 
; For n elements (indices 0 to n-1) in array a
; FOR i = n-1 TO 1
;     r = RND(i)       ; Random number 0 =< r =< i
;     SWAP(a[i],a[r])
;
; In:  HL pointer to the string
;      
;
; Dirty: A
;-----------------------------------------------------------------------------------
shuffle:
    call len

    ; Check string len, if 255 string is too large
    cp a,255
    ret z

    ; dec by 1, so that a = n - 1
    dec a

.next:

    djnz .next

    ret



    endmodule