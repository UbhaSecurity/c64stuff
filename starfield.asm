; Simple Star Field Simulation for Commodore 64
; Press SPACE to exit

; Memory locations for screen memory and color memory
SCREEN    = $0400
COLORRAM  = $D800

; Character set for stars (a simple dot)
STAR_CHAR = $2E

; Colors (white on black background)
WHITE     = $01
BLACK     = $00

; Define start address
        .org $0801
        .word $0801

        ; BASIC header
        .byte $0C, $08, "STARFIELD", $00

        ; Machine code
        .org $080D

start   lda #BLACK         ; Set background color to black
        sta $D021
        lda #STAR_CHAR      ; Set character for stars
        sta $D018

main    jsr init          ; Initialize star field
loop    jsr updateStars   ; Update star positions
        jsr drawStars     ; Draw stars on the screen
        jsr waitFrame     ; Wait for the next frame
        jmp loop          ; Repeat

; Initialize the star field
init    ldx #0            ; Clear screen memory
clear   lda #0
        sta SCREEN, x
        sta COLORRAM, x
        inx
        cpx #40           ; Check if we've cleared the entire screen
        bne clear
        rts

; Update star positions
updateStars
        ldx #0
updateLoop
        lda RANDOM        ; Get a random value (0-255)
        and #3            ; Keep only the lowest 2 bits (0-3)
        sta $2000, x      ; Store it in VIC-II sprite X position register
        inx
        cpx #8            ; Check if we've updated all 8 stars
        bne updateLoop
        rts

; Draw stars on the screen
drawStars
        ldx #0
drawLoop
        lda $2000, x      ; Get the X position of the star
        sta $0400, x      ; Set the star position on the screen
        lda #WHITE        ; Set star color to white
        sta $D800, x      ; Set the star color in color memory
        inx
        cpx #8            ; Check if we've drawn all 8 stars
        bne drawLoop
        rts

; Wait for the next frame
waitFrame
        lda $D012          ; Check the VIC-II raster register
waitLoop
        cmp $D012          ; Wait until it's different from the current value
        beq waitLoop
        rts

; IRQ handler (unused)
irqHandler
        rti

; NMI handler (unused)
nmiHandler
        rti

; Initialize RAM and vectors
        .org $0314
        .word start       ; Autostart address
        .word irqHandler  ; IRQ handler address
        .word nmiHandler  ; NMI handler address

        .end
