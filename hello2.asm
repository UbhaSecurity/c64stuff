* = $801
; this is a sample BASIC program required to start our code
!byte $0c,$08,$0a,$00
!byte $9e ; sys
!text "2068 :-)"
!byte $00,$00,$00,$00

*=$0814

* = $801
;Sample BASIC program required to start the code
!byte $0c,$08,$0a,$00
!byte $9e ;sys
!text "2068 :-)"
!byte $00,$00,$00,$00

* = $0814

;Starfield simulation code starts here
;Initialize variables
lda #$00 ;Initialize X position (horizontal)
sta $d020 ;Set background color (black)
sta $d021 ;Set border color (black)
lda #$0C ;Initialize delay counter
sta delay

;Main loop
mainLoop:
;Update star positions
lda random ;Get a random value (0-255)
and #$07 ;Keep the lower 3 bits (0-7)
sta starX ;Store it as the new X position
lda random ;Get another random value
and #$07 ;Keep the lower 3 bits (0-7)
sta starY ;Store it as the new Y position

;Draw star at the new position
lda starX
sta $0400,x ;Set the pixel in the screen memory
lda starY
sta $0401,x ;Set the color of the pixel

;Delay loop
ldx delay
delayLoop:
dex
bne delayLoop

;Clear the pixel (remove the star)
lda starX
sta $0400,x ;Clear the pixel in the screen memory
sta $0401,x ;Clear the color of the pixel

;Delay loop
ldx delay
clearLoop:
dex
bne clearLoop

;Repeat the loop
jmp mainLoop

;Random number generator (simple XOR-based)
random:
lda $ea31 ;Load value from address $EA31
eor $ea31+1 ;XOR it with the next byte
ror ;Rotate right (shifts in a random bit)
sta $ea31 ;Store the result back to $EA31
ror ;Rotate right again
sta $ea31+1 ;Store the result back to $EA31+1
ror ;Rotate right once more
ror ;Rotate right again
ror ;Rotate right one last time
ror ;Rotate right one more time
ror ;Rotate right one final time
ror ;Rotate right one last time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time
ror ;Rotate right one final time

;Delay value for controlling star movement speed
delay:
!byte $0C

;Variables for star position
starX:
!byte $00

starY:
!byte $00

* = $9E00

