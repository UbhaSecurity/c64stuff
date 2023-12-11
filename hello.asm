* = $801
; this is a sample BASIC program required to start our code
!byte $0c,$08,$0a,$00
!byte $9e ; sys
!text "2068 :-)"
!byte $00,$00,$00,$00

*=$0814

; our code starts here
lda #$00
sta $d020
sta $d021
rts
