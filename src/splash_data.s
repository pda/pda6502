; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export SplashData

.segment "kernal"

SplashData:
;---------
; Splash screen data from Adafruit_SSD1306.cpp
; 128x32 pixels, 512 bytes.
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80
.byte $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $80, $80, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $80, $C0, $E0, $F0, $F8, $FC, $F8, $E0, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $80
.byte $80, $80, $00, $80, $80, $00, $00, $00, $00, $80, $80, $80, $80, $80, $00, $FF
.byte $FF, $FF, $00, $00, $00, $00, $80, $80, $80, $80, $00, $00, $80, $80, $00, $00
.byte $80, $FF, $FF, $80, $80, $00, $80, $80, $00, $80, $80, $80, $80, $00, $80, $80
.byte $00, $00, $00, $00, $00, $80, $80, $00, $00, $8C, $8E, $84, $00, $00, $80, $F8
.byte $F8, $F8, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $E0, $E0, $C0, $80
.byte $00, $E0, $FC, $FE, $FF, $FF, $FF, $7F, $FF, $FF, $FF, $FF, $FF, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $C7, $01, $01
.byte $01, $01, $83, $FF, $FF, $00, $00, $7C, $FE, $C7, $01, $01, $01, $01, $83, $FF
.byte $FF, $FF, $00, $38, $FE, $C7, $83, $01, $01, $01, $83, $C7, $FF, $FF, $00, $00
.byte $01, $FF, $FF, $01, $01, $00, $FF, $FF, $07, $01, $01, $01, $00, $00, $7F, $FF
.byte $80, $00, $00, $00, $FF, $FF, $7F, $00, $00, $FF, $FF, $FF, $00, $00, $01, $FF
.byte $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $03, $0F, $3F, $7F, $7F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $E7, $C7, $C7, $8F
.byte $8F, $9F, $BF, $FF, $FF, $C3, $C0, $F0, $FF, $FF, $FF, $FF, $FF, $FC, $FC, $FC
.byte $FC, $FC, $FC, $FC, $FC, $F8, $F8, $F0, $F0, $E0, $C0, $00, $01, $03, $03, $03
.byte $03, $03, $01, $03, $03, $00, $00, $00, $00, $01, $03, $03, $03, $03, $01, $01
.byte $03, $01, $00, $00, $00, $01, $03, $03, $03, $03, $01, $01, $03, $03, $00, $00
.byte $00, $03, $03, $00, $00, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $01
.byte $03, $03, $03, $03, $03, $01, $00, $00, $00, $01, $03, $01, $00, $00, $00, $03
.byte $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00