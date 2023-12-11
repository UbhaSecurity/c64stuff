* = $0801  ; Set the start address

; BASIC loader to run the machine code
!byte $0C, $08, $0A, $00, $9E, $20, $33, $32, $37, $31, $00, $00, $00

* = $0814  ; Start address for the machine code

; Clear screen code
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

; Entry point
start:
    jsr clearScreen  ; Clear the screen
    jmp start        ; Infinite loop to prevent falling into BASIC

; Unused memory for padding
* = $0900
