* = $0801

; BASIC header
!byte $0C, $08, $0A, $00, $9E, $32, $30, $38, $31, $34, $00, $00, $00

* = $0814

; Entry point
start:
    lda #$02        ; Load a value to change the border color
    sta $d020       ; Change the border color
    lda #$01        ; Load a value to change the background color
    sta $d021       ; Change the background color

    ; Infinite loop to prevent the program from returning to BASIC
infiniteLoop:
    jmp infiniteLoop

; Unused memory for padding
* = $0900
