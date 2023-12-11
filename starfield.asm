* = $801
; Sample BASIC program required to start our code
!byte $0C, $08, $0A, $00
!byte $9E ; sys
!text "2068 :-)"
!byte $00, $00, $00, $00

* = $0814

; Starfield simulation code starts here
; Initialize variables
lda #$00 ; Initialize X position (horizontal)
sta $d020 ; Set background color (black)
sta $d021 ; Set border color (black)
lda #$0C ; Initialize delay counter
sta delay

; Main loop
mainLoop:
; Update star positions
jsr getRandom ; Get a random value (0-255)
and #$07 ; Keep the lower 3 bits (0-7)
sta starX ; Store it as the new X position
jsr getRandom ; Get another random value
and #$07 ; Keep the lower 3 bits (0-7)
sta starY ; Store it as the new Y position

; Calculate screen memory address for star
lda starY
asl ; Multiply Y by 2 (each character is 2 bytes)
asl
sta starAddressL ; Store low byte of address
lda starX
sta starAddressH ; Store high byte of address

; Draw star at the new position
ldx delay

drawStarLoop:
lda #$20 ; Space character
sta $0400,x ; Write space to screen memory
sta $0401,x ; Write space to color memory
dex
bne drawStarLoop

; Delay loop
delayLoop:
dex
bne delayLoop

; Clear the star
ldx starAddressL
lda #$20 ; Space character
sta $0400,x ; Clear the screen memory
sta $0401,x ; Clear the color memory

; Repeat the loop
jmp mainLoop

; Random number generator (simple XOR-based)
getRandom:
lda $ea31 ; Load value from address $EA31
eor $ea31+1 ; XOR it with the next byte
ror ; Rotate right (shifts in a random bit)
sta $ea31 ; Store the result back to $EA31
ror ; Rotate right again
rts

; Delay value for controlling star movement speed
delay:
!byte $0C

; Variables for star position and address
starX:
!byte $00
starY:
!byte $00
starAddressL:
!byte $00
starAddressH:
!byte $00

* = $9E00
