        .org $0801

        ; BASIC header
        .byte $0C, $08, $08, $00, $9E, $32, $30, $36, $31, $32, $00

        ; Machine code
        .org $080D

start   lda #$00          ; Initialize background color to black
        sta $D021
        lda #$2E          ; Set character for stars
        sta $D018

main    jsr init          ; Initialize star field
loop    jsr updateStars   ; Update star positions
        jsr drawStars     ; Draw stars on the screen
        jsr waitFrame     ; Wait for the next frame
        jmp loop          ; Repeat

; Initialize the star field
init    ldx #$00         ; Clear screen memory and color memory
clear   lda #$20
        sta $0400, x
        sta $D800, x
        inx
        cpx #$1F          ; Check if we've cleared the entire screen
        bne clear
        rts

; Update star positions
updateStars
        ldx #$00
updateLoop
        lda $D012          ; Get raster line (vertical blank)
        cmp #$81           ; Check if in the lower half of the screen
        bcc .skipUpdate    ; If not, skip the update
        lda $D020, x       ; Get the current X position of the star
        clc
        adc #$01           ; Move star to the right
        sta $D020, x
.skipUpdate
        inx
        cpx #$08           ; Check if we've updated all 8 stars
        bne updateLoop
        rts

; Draw stars on the screen
drawStars
        ldx #$00
drawLoop
        lda $D020, x       ; Get the X position of the star
        sta $0400, x       ; Set the star position on the screen
        lda #$01           ; Set star color to white
        sta $D800, x       ; Set the star color in color memory
        inx
        cpx #$08           ; Check if we've drawn all 8 stars
        bne drawLoop
        rts

; Wait for the next frame
waitFrame
        lda $D012           ; Check the VIC-II raster register
waitLoop
        cmp $D012           ; Wait until it's different from the current value
        beq waitLoop
        rts
