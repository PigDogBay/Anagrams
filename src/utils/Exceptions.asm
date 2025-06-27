;-----------------------------------------------------------------------------------
;
; Exceptions are here to catch bugs early and to quickly identify faulty code.
; 
; 
; 
; 
; 
;-----------------------------------------------------------------------------------

    module Exceptions


nullPointer:
    ; Copy stack pointer to HL, so you can see who raised the exception
    pop hl
    push hl
.loop:
    jr .loop

slotNotFound:
    ; Copy stack pointer to HL, so you can see who raised the exception
    pop hl
    push hl
.loop:
    jr .loop

tileNotFound:
    ; Copy stack pointer to HL, so you can see who raised the exception
    pop hl
    push hl
.loop:
    jr .loop



    endmodule