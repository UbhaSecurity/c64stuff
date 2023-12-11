.org $C000

start
    lda #$00
    sta $D021
    lda #$2E
    sta $D018

main
    jsr init
loop
    jsr updateStars
    jsr drawStars
    jsr waitFrame
    jmp loop

init
    ldx #$00
clear
    lda #$20
    sta $0400, x
    sta $D800, x
    inx
    cpx #$1F
    bne clear
    rts

updateStars
    ldx #$00
updateLoop
    lda $D012
    cmp #$81
    bcc skipUpdate
    lda $D020, x
    clc
    adc #$01
    sta $D020, x
skipUpdate
    inx
    cpx #$08
    bne updateLoop
    rts

drawStars
    ldx #$00
drawLoop
    lda $D020, x
    sta $0400, x
    lda #$01
    sta $D800, x
    inx
    cpx #$08
    bne drawLoop
    rts

waitFrame
    lda $D012
waitLoop
    cmp $D012
    beq waitLoop
    rts
