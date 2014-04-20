; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export SleepXMs
.export SleepOneMs

.segment "kernal"

; Sleep for X milliseconds (assuming 1 MHz).
SleepXMs:
  TXA
  PHA
@loop:
  JSR SleepOneMs
  DEX
  BNE @loop
  PLA
  TAX
  RTS

; Sleep for 196*5=1280 (plus about 20) cycles == ~1 ms at 1 MHz
SleepOneMs:
  TXA
  PHA
  LDX #196
@loop:
  DEX         ; 2 cycles
  BNE @loop   ; 3 cycles (+2 if branching to new page)
  PLA
  TAX
  RTS

