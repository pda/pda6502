; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export CopyPages

.segment "kernal"

; Copy X pages of data from *$10,$11 to *$12,$13.
CopyPages:
;--------
  PHA
  TXA
  PHA
  TYA
  PHA
  LDA $11
  PHA
  LDA $13
  PHA
@eachPage:
  LDY #$00 ; byte offset within page.
@eachByte:
  LDA ($10),Y
  STA ($12),Y
  INY ; zero for $FF -> $00 wrap.
  BNE @eachByte
  INC $11
  INC $13
  DEX
  BNE @eachPage
  PLA
  STA $13
  PLA
  STA $11
  PLA
  TAY
  PLA
  TAX
  PLA
  RTS
