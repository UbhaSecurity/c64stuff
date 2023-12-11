* = $0801  ; Set the start address

; BASIC loader to run the program
!byte $0C, $08, $0A, $00, $9E, $20, $33, $32, $37, $31, $00, $00, $00

* = $0814  ; Start address for the code

; Variables
starX = $FC   ; Temporary storage for X position of star
starY = $FD   ; Temporary storage for Y position of star
delay = $FE   ; Delay counter

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

; Starfield simulation code starts here
mainLoop:
    jsr randomPosition ; Get a random position for the star
    sta starX
    lda starY
    jsr plotStar      ; Plot the star

    ldx #50          ; Set delay
delayLoop:
    dex
    bne delayLoop

    lda starX
    lda starY
    jsr clearStar    ; Clear the star

    jmp mainLoop

; Generate random X and Y positions for the star
randomPosition:
    lda $D012        ; Random number from the C64
    and #$27         ; Limit X to screen width
    sta starX
    lda $D012        ; Random number for Y
    and #$18         ; Limit Y to screen height
    sta starY
    rts

; Plot a star at the given X and Y position
plotStar:
    lda #$2A        ; '*' character
    sta $0400, x    ; Plot the star at the position
    rts

; Clear a star at the given X and Y position
clearStar:
    lda #$20        ; Space character
    sta $0400, x    ; Clear the star at the position
    rts

; Entry point
start:
    jsr clearScreen  ; Clear the screen
    jmp mainLoop

; Unused memory for padding
* = $0900
