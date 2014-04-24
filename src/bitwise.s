.export ShiftZpXLeftByY
.export ShiftZpXRightByY

.segment "kernal"

; Left shift zp,X by Y bits.
ShiftZpXLeftByY:
  TYA
  PHA
@loop:
  CPY #0
  BEQ @done
  ASL $00,X
  DEY
  JMP @loop
@done:
  PLA
  TAY
  RTS

; Left shift zp,X by Y bits.
ShiftZpXRightByY:
  TYA
  PHA
@loop:
  CPY #0
  BEQ @done
  LSR $00,X
  DEY
  JMP @loop
@done:
  PLA
  TAY
  RTS
