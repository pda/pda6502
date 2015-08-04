; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.import HaltWithCodeX
.segment "sd"

BlinkFromSdCard:
  LDX #10
  JSR HaltWithCodeX
