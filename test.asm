* = $0801  ; Set the start address

; BASIC loader to run the machine code
!byte $0C, $08, $0A, $00, $9E, $32, $30, $38, $31, $34, $00, $00, $00

* = $0814  ; Start address for the machine code

; Entry point
start:
    jmp clearScreen  ; Jump to clearScreen subroutine

; Clear screen subroutine
clearScreen:
    lda #$00
    sta $d020   ; Set the border color to black
    sta $d021   ; Set the background color to black

    ldx #$00
clearLoop:
    lda #$20    ; Space character
    sta $0400,x
    inx
    bne clearLoop
    cpx #$E8    ; Check if all 1000 characters are cleared (40 columns x 25 rows)
    bcc clearLoop

    rts  ; Return from subroutine

; Unused memory for padding
* = $0900
