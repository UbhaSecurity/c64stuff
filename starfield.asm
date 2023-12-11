* = $0801  ; Set the start address

; BASIC loader to run the program
!byte $0C, $08, $0A, $00, $9E, $20, $30, $36, $38, $30, $00, $00, $00

* = $080D  ; Start address for the actual code

; Variables
starX = $40
starY = $41
delay = $42

* = $0814  ; Start address for the code

; Starfield simulation code
mainLoop:
    lda #0      ; Initialize X position (horizontal)
    sta starX
    lda #$0C    ; Initialize delay counter
    sta delay

drawLoop:
    lda starX   ; Get the X position
    jsr plotStar

    lda starY   ; Get the Y position
    jsr plotStar

    jsr delayLoop ; Delay loop

    lda starX   ; Clear the star
    jsr plotStar

    lda starY
    jsr plotStar

    jsr delayLoop ; Delay loop

    jmp drawLoop

; Plot a star at the given X and Y position
plotStar:
    sta $0400, x ; Set the pixel in the screen memory
    lda starY
    sta $0401, x ; Set the color of the pixel
    rts

; Delay loop
delayLoop:
    ldx delay
delayLoopInner:
    dex
    bne delayLoopInner
    rts

; Initialize variables
init:
    lda #$00
    sta starX
    sta starY
    lda #$0C
    sta delay
    rts

; Entry point
start:
    jsr init
    jmp mainLoop

; Unused memory for padding
* = $0900
