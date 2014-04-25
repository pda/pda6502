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
  CLC
  SBC #$40
  BCS notAlpha
  TYA
  CLC
  SBC #$5A
  BCC notAlpha
  TYA
  CLC
  SBC #$3F      ; subtract $3F for alpha chars
  TAY
notAlpha:
  RTS
.ENDPROC
