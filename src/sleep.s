; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export SleepOneMs
.export SleepXMs
.export SleepXSeconds

.segment "kernal"

.PROC SleepXSeconds
  TXA
  PHA
  TYA
  PHA
  TXA ; move loop counter from X ..
  TAY ; .. to Y
  LDX #250 ; 250ms per SleepXMs
loop:
  CPY #0
  BEQ done
  JSR SleepXMs
  JSR SleepXMs
  JSR SleepXMs
  JSR SleepXMs
  DEY
  JMP loop
done:
  PLA
  TAY
  PLA
  TAX
  RTS
.ENDPROC

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

