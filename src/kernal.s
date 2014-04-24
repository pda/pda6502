; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main
.import Ssd1306Init
.import Ssd1306WriteScreen
.import FontData
.import CopyPages
.import ShiftZpXLeftByY
.import ShiftZpXRightByY

.segment "kernal"

ssd1306_buffer = $7000 ; page-aligned 512 byte buffer

Main:
;--------

  JSR Ssd1306Init

  JSR WriteLetter

  ; Store pointer to data at $10
  LDA #.LOBYTE(ssd1306_buffer)
  STA $10
  LDA #.HIBYTE(ssd1306_buffer)
  STA $11

  JSR Ssd1306WriteScreen

Halt:
;--------
NOP
JMP Halt


; attempt to write the "@" char (first font char) to screen buffer.
; Overwrites $12.
WriteLetter:
  LDY #0 ; font y-coordinate (bit index); screen x-coordinate (byte index)
@eachByte:
  LDX #7 ; font x-coordinate (byte index); screen y-coordinate (bit index)
  LDA #0
  STA ssd1306_buffer,Y ; zero the byte
@eachBit:
  ; create font bit mask in tmp
  LDA #%10000000
  STA $12               ; store initial bitmask at $0012
  TXA
  PHA                   ; save X on stack
  LDX #$12              ; store ptr to $12 in X
  JSR ShiftZpXRightByY  ; right-shift value at X=$12 Y times.
  PLA                   ; restore X from stack
  TAX
  LDA $12               ; resulting bitmask in A
  AND FontData,X        ; AND with font data
  BEQ @donePixel        ; branch if bit was clear
  ; create display bit mask in tmp
  TXA
  PHA                   ; save X on stack
  TYA
  PHA                   ; save Y on stack
  TXA
  TAY                   ; Y <- X for shift function (restored later)
  LDA #1
  STA $12               ; store initial bitmask at $0012
  LDX #$12              ; store ptr to $12 in X
  JSR ShiftZpXLeftByY   ; left-shift value at X=$12 Y times.
  PLA                   ; restore Y from stack
  TAY
  PLA                   ; restore X from stack
  TAX
  LDA $12               ; resulting bitmask in A
  ; apply to ssd buffer
  ORA ssd1306_buffer,Y  ; OR with destination data
  STA ssd1306_buffer,Y  ; Store in destination data.

@donePixel:

  DEX
  CPX #$FF
  BNE @eachBit

  INY
  CPY #7
  BNE @eachByte

  RTS
