; Memory Addresses
* = $0801
!byte $0c,$08,$0a,$00,$9e,$20,$32,$33,$30,$34,$00,$00,$00 ; BASIC auto start at $0900 

screen_color = $f7
color = $f8
color_h = $f9
velocity = $fa
cursor = $fb ; locations in screen memory
cursor_h = $fc
cursor_clear = $fd 
cursor_clear_h = $fe
bitmask_clear = $ff

x_pos = $1200 ; +32
x_pos_h = $1220 ; +32
y_pos = $1240 ; +32
cursor_buffer = $1260 ; + 32
cursor_buffer_h = $1280 ; + 32
bitmask_buffer = $12a0 ; + 32

size = 32

; Entry Point
* = $0900
  jsr init
  jsr blank_screen
  jsr init_starfield

move_loop:
  ; Call subroutine to draw stars on the screen
  jsr draw_stars
  ; Call subroutine to move stars based on their velocities
  jsr move_stars
  ; Call subroutine to update star colors based on velocity
  jsr update_star_colors
  ; Check for the exit condition
  jsr check_exit_key
  ; Wait for vertical sync
  jsr vsync_wait
  ; Return to the beginning of the loop
  rts

init:
  lda #$04
  sta cursor_h
  sta cursor_clear_h

  lda #$00
  sta $d020 ; Set border color to black
  sta $d021 ; Set background color to black

  lda #%00010000
  sta $d018

  lda #%00110111
  sta $d011 ; Set high-resolution mode and 25 rows for a PAL system

  lda #0
  sta cursor
  lda #0
  sta cursor_h
  ; Initialize other variables as needed
  rts

blank_screen:
  ldx #$00 ; Initialize X for screen memory loop
  ldy #$00 ; Initialize Y for high byte index

clear_screen_loop:
  lda #$20 ; Space character
  sta $0400,x ; Write to screen memory
  sta $d800,x ; Write to color memory
  inx
  bne clear_screen_loop
  inc cursor_h
  inc cursor_clear_h
  cpy #$28 ; Check if Y reached 40 rows (1000 bytes)
  bne clear_screen_loop

  lda cursor_h
  cmp #$08 ; Check for end of screen memory range
  bcc clear_screen_end

  lda #$00 ; Reset cursor_h
  sta cursor_h

  lda cursor_clear_h
  cmp #$08 ; Check for end of color memory range
  bcc clear_screen_end

  lda #$00 ; Reset cursor_clear_h

clear_screen_end:
  rts

vsync_wait:
  ; Load the value of $D012 into the accumulator
  lda $d012

  ; Compare the accumulator with the VSYNC threshold (PAL system vertical blank)
  cmp #$fb

  ; If the comparison result is not equal (VSYNC not yet reached), keep waiting
  bne vsync_wait

  ; If the comparison result is equal (VSYNC reached), proceed with the code
  rts

videoloop
      lda #0
      sta (cursor), y
      iny
      bne videoloop      ; Loop unless high bit needs increment
      inc cursor_h
      lda cursor_h       ; Check end of range
      cmp #$40           ; 8000 bytes
      beq blank_screen   ; Finished
      jmp videoloop
      rts

init_starfield
    ldx #0
next_star
    ; Set initial positions within screen bounds
    lda #0
    sta x_pos, x
    sta x_pos_h, x ; Assuming x_pos_h is meant to handle overflow from x_pos
    lda #0
    sta y_pos, x
    ; Now call init_star to set initial values
    jsr init_star
    inx
    cpx #size
    bcc next_star
    rts


draw_stars
      ldy #0
draw_star
      jsr plot_star       ; Plot star index y, return with pixel bit index in x
      txa
      pha
      jsr set_color      ; Set color in screen memory using star at index y 
      jsr color_enhancement_logic  ; Call the color enhancement logic
      pla
      tax
      lda cursor_buffer_h, y
      beq save_cursor    ; Skip if buffer is empty
      sta cursor_clear_h
      lda cursor_buffer, y
      sta cursor_clear
      lda bitmask_buffer, y
      sta bitmask_clear
      tya
      pha
      ldy #0
      lda (cursor_clear), y
      and bitmask_clear  ; Clear star
      sta (cursor_clear), y
      pla
      tay
save_cursor
      lda cursor
      sta cursor_buffer, y ; Store coordinate in buffer
      lda cursor_h
      sta cursor_buffer_h, y
      lda x_bit_clear, x
      sta bitmask_buffer, y ; Store bitmask in buffer
      iny
      cpy #size
      bcc draw_star
      rts

update_positions
      lda x_pos
      cmp #40            ; Compare x_pos with 40
      bcc x_pos_ok       ; If less, it's okay
      lda #0             ; Reset x_pos to 0
      sta x_pos
      inc y_pos          ; Increment y_pos as we wrapped a line
x_pos_ok
      lda y_pos
      cmp #25            ; Compare y_pos with 25
      bcc y_pos_ok       ; If less, it's okay
      lda #0             ; Reset y_pos to 0 (top of the screen)
y_pos_ok
      rts

move_stars
       ldx #0
move_next_star
       jsr update_velocity  ; Update velocity
       lda x_pos, x
       clc
       adc velocity, x
       sta x_pos, x
       jsr update_positions  ; Ensure x_pos and y_pos are within bounds
       inx
       cpx #size
       bcc move_next_star
       rts

update_velocity
    ldx #0
update_vel
    lda y_pos, x        ; Load the Y position of the current star
    and #%00000001      ; Isolate the least significant bit
    clc                 ; Clear the carry flag for addition
    adc #1              ; Add 1 (so velocity is either 1 or 2)
    sta velocity, x     ; Store the updated velocity

    lda x_pos, x        ; Load the X position of the current star
    clc                 ; Clear the carry flag for addition
    adc velocity, x     ; Add the velocity to the X position
    sta x_pos, x        ; Store the new X position

    lda x_pos_h, x      ; Load the high byte of the X position
    adc #0              ; Add carry, if any, from the previous addition
    sta x_pos_h, x      ; Store the new high byte of the X position

    inx                 ; Move to the next star
    cpx #size           ; Check if all stars have been updated
    bcc update_vel      ; If not, loop back to update the next star
    rts                 ; Return from subroutine

update_star_colors
    ldx #0
update_color
    lda cursor_buffer_h, x
    beq color_loop_done
    lda cursor_buffer, x
    tax
    lda color_h, y
    sta screen_color
    lda color, y
    tay
    pha
    lda (color), y
    and #%00001111
    ora screen_color
    sta (color), y

    ; Implement color enhancement logic based on velocity
    lda velocity, x       ; Load velocity of the current star
    cmp #2                ; Compare with a threshold (e.g., 2)
    bcc normal_color      ; If velocity is less than 2, use normal color

    ; For faster-moving stars (velocity >= 2), change the color
    lda #$0F              ; Set a different color (e.g., bright white)
    sta (color), y

normal_color
    pla
    tay
color_loop_done
    inx
    cpx #size
    bcc update_color

    rts

color_enhancement_logic
    ldx #0                ; Initialize X index to 0
enhance_color_loop
    lda x_pos, x         ; Load X position of the star
    clc                  ; Clear the carry flag
    adc y_pos, x         ; Add Y position to X position
    and #%00000111       ; Mask off all but the 3 least significant bits
    tax                  ; Transfer the result to X index
    lda color_h, x       ; Load the high byte of color based on position
    sta screen_color     ; Store it as the screen color
    lda color, x         ; Load the low byte of color based on position
    tay                  ; Transfer it to Y
    pha                  ; Push it onto the stack
    lda (color), y       ; Load the color from the color lookup table
    and #%00001111       ; Mask off all but the 4 least significant bits
    ora screen_color     ; OR with the screen color
    sta (color), y       ; Store the updated color in the lookup table
    pla                  ; Pull the original Y value from the stack
    tay                  ; Transfer it back to Y
    inx                  ; Increment X index for the next star
    cpx #size            ; Check if all stars have been processed
    bcc enhance_color_loop ; If not, repeat the loop
    rts                  ; Return from the subroutine
init_star
    lda #0
    sta x_pos_h, x
    jsr rnd
    lda $d012        ; Use current raster line for randomness
    and #%00111111   ; Get a more random value for X
    clc
    adc x_pos, x
    sta x_pos, x
    lda #0
    adc x_pos_h, x
    sta x_pos_h, x
    jsr rnd
    lda $d012        ; Use current raster line for randomness
    and #%11000000   ; Get a different random value for Y
    sta y_pos, x
    rts

regen_y
    jsr rnd
    lda $d012        ; Use current raster line for randomness
    and #%11000111   ; Get a more random value for Y
    sta y_pos, x
    rts

rnd
    txa
    pha
    jsr $e09a        ; Call the C64's built-in RNG
    eor $d012        ; XOR with the current raster line for added randomness
    pla
    tax
    rts

check_exit_key
    lda #$EF           ; Set bit 4 to input (11101111)
    sta $DC02          ; Set column for SPACE key (Column 4)
    lda $DC01          ; Read row data
    and #$80           ; Check only bit 7 (Row 7, where SPACE key is located)
    beq no_exit        ; Branch if SPACE key is not pressed

    ; Call exit_message subroutine when SPACE key is pressed
    jsr exit_message   ; Call the exit_message subroutine
    jmp clean_exit     ; Jump to clean exit routine

no_exit
    rts               ; Return without exiting if SPACE key is not pressed

; Define the exit_message subroutine here
exit_message
    ; Add your code here to display an exit message or perform other actions
    ; You can use screen codes or PETSCII codes to display the message
    ; For example:
    lda #13            ; PETSCII code for Return (CR)
    jsr $ffd2          ; Output the character to the screen
    lda #10            ; PETSCII code for Line Feed (LF)
    jsr $ffd2          ; Output the character to the screen
    rts               ; Return from the subroutine

; Clean exit routine
clean_exit
    ; Add logic here to clear the screen, reset system settings, etc.
    jmp $A474          ; Jump to BASIC warm start vector

; Routine to set the cursor position
; X-register: X-coordinate (0-39)
; Y-register: Y-coordinate (0-24)

set_cursor
    sty $d6             ; Store Y-coordinate in temporary location
    tya                 ; Transfer Y-coordinate to accumulator
    asl                 ; Multiply Y by 2
    asl                 ; Multiply Y by 4 (total Y*8)
    clc                 ; Clear carry for addition
    adc $d6             ; Add original Y (total Y*8 + Y = Y*9)
    tax                 ; Transfer result to X-register
    lda #0              ; Clear accumulator for multiplication
    ldy #40             ; Set Y for multiplication by 40 (row width)
    jsr mul_8bit        ; Call multiplication subroutine (result in A and X)
    tay                 ; Transfer high byte to Y-register
    clc                 ; Clear carry for addition
    adc $d020           ; Add X-coordinate (low byte)
    bcc no_carry        ; Branch if no carry
    iny                 ; Increment high byte if there was a carry
no_carry
    sta $d021           ; Store low byte in temporary location
    lda $d021           ; Load low byte of screen memory address
    sta $d1           ; Store in CIA 1 data port A (keyboard matrix column)
    lda $d020           ; Load high byte of screen memory address
    sta $d1             ; Store in CIA 1 data port B (keyboard matrix row)
    rts                 ; Return from subroutine

; 8-bit multiplication subroutine
; Multiplies A by Y, result in A (low byte) and X (high byte)
mul_8bit
    ldx #0              ; Clear high byte of result
mul_loop
    bcc skip_add        ; Skip addition if carry is clear
    clc                 ; Clear carry for addition
    adc $d020           ; Add multiplicand to low byte of result
    bcc no_carry_add    ; Branch if no carry from addition
    inx                 ; Increment high byte if there was a carry
no_carry_add
skip_add
    asl $d020           ; Shift multiplicand left
    rol                 ; Rotate result left through carry
    dey                 ; Decrement multiplier
    bne mul_loop        ; Repeat until multiplier is zero
    rts                 ; Return from subroutine

plot_star
    lda y_pos, y       ; Load the Y position of the star
    lsr               ; Divide by 8 (equivalent to shifting right 3 times)
    lsr
    lsr
    sta cursor_h      ; Store the result in cursor_h (high byte of cursor)
    sta cursor        ; Also store it in cursor (low byte of cursor)
    lda #0            ; Initialize X-coordinate multiplier
    ldx #6            ; Load X with 6 (number of times to shift left)
y_low_mul
    asl cursor        ; Shift cursor left (effectively multiplying it by 2)
    rol               ; Rotate left through carry (multiply by 2)
    dex               ; Decrement X
    bne y_low_mul     ; Repeat until X becomes zero
    clc               ; Clear carry flag
    adc cursor_h      ; Add cursor_h to the result
    sta cursor_h      ; Store the final high byte of cursor
    lda y_pos, y      ; Load Y position again
    and #%00000111    ; Mask off all but the 3 least significant bits
    clc               ; Clear carry flag
    adc cursor        ; Add cursor (low byte of cursor)
    sta cursor        ; Store the final low byte of cursor
    lda cursor_h      ; Load high byte of cursor
    adc #0            ; Add carry, if any, from the previous addition
    sta cursor_h      ; Store the updated high byte of cursor
    lda x_pos, y      ; Load X position of the star
    and #%11111000    ; Mask off the 3 least significant bits
    clc               ; Clear carry flag
    adc cursor        ; Add cursor (low byte of cursor)
    sta cursor        ; Store the final low byte of cursor
    lda cursor_h      ; Load high byte of cursor
    adc x_pos_h, y    ; Add the high byte of X position
    sta cursor_h      ; Store the updated high byte of cursor
    lda x_pos, y      ; Load X position again
    and #%00000111    ; Mask off all but the 3 least significant bits
    tax               ; Transfer X to the index register (X)
    lda cursor_h      ; Load high byte of cursor
    clc               ; Clear carry flag
    adc #$20          ; Add $20 for the video offset
    sta cursor_h      ; Store the updated high byte of cursor
    tya               ; Transfer Y to the accumulator
    pha               ; Push it onto the stack
    ldy #0            ; Initialize Y to zero
    lda (cursor), y   ; Load the byte from screen memory at the cursor position
    ora x_bit_set, x  ; OR with the appropriate pixel bit in the lookup table
    sta (cursor), y   ; Store the result back in screen memory
    pla               ; Pull the original Y value from the stack
    tay               ; Transfer it to Y
    rts               ; Return from the subroutine

; The set_color subroutine is responsible for setting the color of a star.
; It calculates the color memory address based on the star's position and
; ensures that the address falls within the valid color memory range.
set_color
    lda y_pos, y       ; Load the Y position of the star
    lsr                ; Divide by 8 to get the row
    lsr
    lsr
    tax                ; Transfer to X to use as an offset in the lookup table

    lda y_screen_h, x  ; Get the high byte of the screen address from the table
    sta color_h        ; Store it in color_h
    lda y_screen, x    ; Get the low byte of the screen address from the table
    sta color          ; Store it in color

    lda x_pos_h, y     ; Get the high byte of the X position
    lsr                ; Divide by 8 to check if X is less than 320
    lda x_pos, y       ; Get the low byte of the X position
    ror                ; Combine with the previous result
    lsr
    lsr                ; Adjust to the correct screen column
    clc
    adc color          ; Add to the low byte of the screen address
    sta color          ; Store it in color
    lda #04            ; Set for the $0400 starting address
    adc color_h        ; Add to the high byte of the screen address
    and #$0f           ; Ensure it doesn't exceed the color memory range
    sta color_h        ; Store it in color_h

    lda y_pos, y       ; Use the low 4 bits of the Y position for color
    asl
    asl
    asl
    asl
    cmp #0
    bne save_color     ; Proceed if not zero
    lda #16            ; Set black stars to white for visibility
save_color
    sta screen_color   ; Store the color value for later use
    tya                ; Transfer Y to A (cleanup from previous operations)
    pha                ; Push A onto the stack to preserve the value
    ldy #0             ; Reset Y to zero for indirect addressing
    lda (color), y     ; Load the color memory at the calculated address
    and #%00001111     ; Clear the upper 4 bits to set the new color
    ora screen_color   ; Combine with the new color value
    sta (color), y     ; Store the new color in color memory
    pla                ; Restore the original A value from the stack
    tay                ; Transfer A back to Y
    rts                ; Return from subroutine


x_bit_set
    !byte $80,$40,$20,$10,$08,$04,$02,$01
x_bit_clear
    !byte $7F,$BF,$DF,$EF,$F7,$FB,$FD,$FE
y_screen ; *40 lookup for screen memory
    !byte $00,$28,$50,$78,$A0,$C8,$F0,$18
    !byte $40,$68,$90,$B8,$E0,$08,$30,$58
    !byte $80,$A8,$D0,$F8,$20,$48,$70,$98
    !byte $C0
y_screen_h
    !byte $00,$00,$00,$00,$00,$00,$00,$01
    !byte $01,$01,$01,$01,$01,$02,$02,$02
    !byte $02,$02,$02,$02,$02,$03,$03,$03
    !byte $03
