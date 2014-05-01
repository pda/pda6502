; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.segment "kernal"

.export AsciiToPetscii

; Converts an ASCII char to a PETSCII char.
; Y: ascii (mutates)
; Already correct: !#$%&*()+-=0123456789;:'<>,./
; "@" and A-Z need $3F subtracted.
; Not correct: |_
.PROC AsciiToPetscii
  ; ASCII $40 to $5A (@, A-Z) map to PETSCII $0 to $something
  TYA
  SEC
  SBC #$40
  BCC notAlpha  ; if Y < $40: skip
  TYA
  SEC
  SBC #$5A
  BCS notAlpha  ; if Y > $5A: skip
  TYA
  SEC
  SBC #$40      ; subtract $40 for alpha chars
  TAY
  JMP end
notAlpha:
  TYA
  SEC
  SBC #$1F
  BCS notLow    ; if Y >= 32 (or 31?): skip
  TYA
  CLC
  ADC #64       ; Y+=64 for 0..31
  TAY
  JMP end
notLow:
end:
  RTS
.ENDPROC
