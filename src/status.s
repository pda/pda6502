; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export BlinkOnce
.export HaltWithCodeX

.segment "kernal"

.import SleepXMs
.import SleepXSeconds

; VIA port A
via_port = $9001
via_ddr = $9003
status_mask = %00000001

; Debugging: blink entire port A; 100ms on, 100ms off.
.PROC BlinkOnce
  PHA
  TXA
  PHA
  JSR setDataDirection
  JSR statusHigh
  LDX #200
  JSR SleepXMs
  JSR statusLow
  LDX #200
  JSR SleepXMs
  PLA
  TAX
  PLA
  RTS
.ENDPROC

.PROC HaltWithCodeX
  TXA
  PHA ; store original X
  JSR setDataDirection
eachPattern:
  PLA
  TAY ; restore original X into Y
  PHA ; re-save original X
eachPulse:
  CPY #0
  BEQ donePattern
  JSR statusHigh
  LDX #100
  JSR SleepXMs
  JSR statusLow
  LDX #100
  JSR SleepXMs
  DEY
  JMP eachPulse
donePattern:
  LDX #1
  JSR SleepXSeconds ; delay between patterns.
  JMP eachPattern ; repeat pattern
.ENDPROC

.PROC setDataDirection
  LDA via_ddr
  ORA #status_mask
  STA via_ddr
  RTS
.ENDPROC

.PROC statusHigh
  LDA via_port
  ORA #status_mask
  STA via_port
  RTS
.ENDPROC

.PROC statusLow
  LDA via_port
  AND #<~status_mask
  STA via_port
  RTS
.ENDPROC
