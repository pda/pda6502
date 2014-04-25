; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.import FontData
.export FontSelectChar

.segment "kernal"

; X: font_ptr zero-page address (currently must be < 32)
; Y: char index
FontSelectChar:
  TYA
  PHA      ; save
  LDA $10
  PHA      ; save
  LDA $11
  PHA      ; save

  ; initialize base pointer
  LDA #.LOBYTE(FontData)
  STA 0,X
  LDA #.HIBYTE(FontData)
  STA 1,X

  ; char index Y * 8 = $10,11 byte index
  TYA
  STA $10 ; lo
  LDA #0
  STA $11 ; hi
  CLC
  ROL $10
  ROL $11 ; x2
  ROL $10
  ROL $11 ; x4
  ROL $10
  ROL $11 ; x8

  ; add 16-bit byte-index at $10 to base font pointer at $00,X.
  CLC
  LDA 0,X
  ADC $10
  STA 0,X
  LDA 1,X
  ADC $11
  STA 1,X

  PLA
  STA $11  ; restore
  PLA
  STA $10  ; restore
  PLA
  TAY      ; restore
  RTS
