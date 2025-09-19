;-----------------------------------------------------------------------------------
; Module List
;
; Simple list, limitations:
; - Uses a fixed buffer
; - No bounds checks
; 
;-----------------------------------------------------------------------------------
    module List


;-----------------------------------------------------------------------------------
;
; Function: clear() 
;
; Sets the count to 0, effectively clearing the list
; 
;  In: -
; Out: - 
;
; Dirty: A
;
;-----------------------------------------------------------------------------------
clear:
    xor a
    ld (count),a
    ret

;-----------------------------------------------------------------------------------
;
; Function: append(uint8 element) 
;
; Adds the element to the end of the list and increases the count by 1
; 
;  In: A - element to add to the list
; Out: -  
;
; Dirty: None
;
;-----------------------------------------------------------------------------------
append:
    push af,bc,hl
    ld b,a
    ld a,(count)
    ld hl,list
    add hl,a
    ld (hl),b
    inc a
    ld (count),a
    pop hl,bc,af
    ret

;-----------------------------------------------------------------------------------
;
; Function: getAt(uint8 index) -> uint8  
;
; Retrieves the value at the index
; 
;  In: A = Index
; Out: B = Value  
;
; Dirty: None
;
;-----------------------------------------------------------------------------------
getAt:
    push hl
    ld hl,list
    add hl,a
    ld b,(hl)
    pop hl
    ret

;-----------------------------------------------------------------------------------
;
; Function: getRandom() -> uint8 
;
;  Returns a random element. Note will return 0 if there are 0 elements
; 
;  In: -
; Out: A = Value pick at a random index 
;
; Dirty: None
;
;-----------------------------------------------------------------------------------
getRandom:
    ld a,(count)
    or a
    ;Return 0 for when empty
    ret z

    push bc

    call Maths.rnd
    call getAt
    ld a,b

    pop bc

    ret 


;-----------------------------------------------------------------------------------
;
; Function: firstIndexOf(uint8 valueToFind) -> 
;
; Searches for the value in the list
; 
;  In: A = value to find
; Out: C = index found at, or 255 (-1) if not found
;
; Dirty: B
;
;-----------------------------------------------------------------------------------
firstIndexOf:
    push af,hl
    ld hl,count
    ld b,a
    ld a,(count)
    add hl,a
    ld c,a ; c = count
    ld a,b ; a = value
    ld b,0 ; b not used
    cpdr
    jr z, .found    
    ld c,255
.found:
    pop hl,af
    ret


;-----------------------------------------------------------------------------------
;
; Function: foreach(uint16* functionPtr(uint8 value)) 
;
; Iterates through each element of the list passing it to the function
; The function receives the value in the A register, use 'ret' to exit
; 
;  In: HL = pointer to the function
; Out: - 
;
; Dirty: ALL
;
;-----------------------------------------------------------------------------------
foreach:
    ;Store function pointer into DE
    ex de,hl
    ld hl,count
    ld b,(hl)
.loop:
    inc hl
    ld a,(hl)
    push bc,de,hl
    ;Retrieve function ptr from DE and simulate call (HL)
    ex de,hl
    call .callHL

    pop hl,de,bc
    djnz .loop
    ret
.callHL:
    jp (hl)

; -mv List.count 65
count:
    db 0
list:
    block 64

    endmodule
