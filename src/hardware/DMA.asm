;-----------------------------------------------------------------------------------
; 
; The DMA (Direct Memory Access) is a device that channels bytes from a source port
; to a destination port. A port can be an address in memory or an IO port. To use
; the DMA you write a small 'program' that sets up the DMA registers and then enable
; the DMA to run. The DMA executes independently* of the Z80 CPU and is 20x faster
; than a comparable Z80 block transfer operation (eg LDIR). (* Will stop the CPU
; until complete when in continuous mode)
; 
; The Next's DMA is single channel with two ports A and B, these can either be source 
; or destination, IO or memory, set to auto-increment/auto-decrement/fixed.
; 
; 
; 
; See page 43 of the Spectrum Next Assembly Dveloper for details
; 
;-----------------------------------------------------------------------------------
    
    module DMA

;-----------------------------------------------------------------------------------
;
; Function: copyBank(uint8 src, uint8 dest)
;
; Copies data from src bank to dest bank, banks are 8k MMU
;
;
; In:
;       H - source bank
;       L - Destination bank
;
; Dirty: A
;-----------------------------------------------------------------------------------
copyBank:
    push hl
    push bc

    ; swap out ROM with banks src (H) and dest (L)
    ld a,h
    nextreg MMU_0,a
    ld a, l
    nextreg MMU_1,a

    ;Upload the DMA program
    ld hl, .dmaProgram
    ld b, .dmaProgramLength
    ld c, DMA_PORT
    otir

    ; Restore ROM
    nextreg MMU_0, $FF
    nextreg MMU_1, $FF
    
    pop bc
    pop hl
    ret

;See page p49 of the ZX Next Assembly Developer for details on WR bits
; ' apostrophes are used to split up the bit fields for readability, sjasm will strip'em out
.dmaProgram:
	DB %1'00000'11		    ; WR6 - Command Register '00000' Disable DMA
	DB %0'11111'01		    ; WR0 - 11 port A start address, 11 length, 1 dir A->B
	DW $0000		        ; Port A start address (MMU_0 start address is 0x0000)
	DW 8*1024			    ; Transfer length (8k - size of a bank)
	DB %0'0010'100		    ; WR1 - Port A, no timing 0/ increment 01 / memory 0
	DB %0'0010'000		    ; WR2 - Port B, no timing 0/ increment 01 / memory 0
	DB %1'01'0'11'01		; WR4 - 01 continuous mode (stops CPU) [0 mask] 11 Port B address
	DW 8*1024               ; Port B address, MMU_1 starts at 8192
	DB %10'00'0010          ; WR5 - 0 Stop on end of block, 0 CE only
	DB %1'10011'11		    ; WR6 - 10011 load addresses into DMA counters
	DB %1'00001'11		    ; WR6 - 00001 Enable DMA - run the program
.dmaProgramLength = $ - .dmaProgram


    endmodule