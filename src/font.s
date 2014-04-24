; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.import FontData
.export FontSelectChar

.segment "kernal"

; X: font_ptr zero-page address (currently must be < 32)
; Y: char index
FontSelectChar:
  LDA $10
  PHA      ; save $10 on stack
  TYA
  PHA      ; save Y on stack
  TYA
  ASL
  ASL
  ASL
  STA $10  ; $10 = Y * 8
  CLC
  LDA #.LOBYTE(FontData)
  ADC $10
  STA 0,X
  BCS @hasCarry
  JMP @noCarry
@hasCarry:
  LDY #.HIBYTE(FontData)
  INY
JMP @carryDone
@noCarry:
  LDY #.HIBYTE(FontData)
@carryDone:
  STY 1,X
  PLA      ; restore Y
  TAY
  PLA      ; restore $10
  STA $10
  RTS
