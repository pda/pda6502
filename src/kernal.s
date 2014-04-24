; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main
.import Ssd1306Init
.import Ssd1306WriteScreen
.import SsdNextSegment
.import FontData
.import FontSelectChar
.import CopyPages
.import ShiftZpXLeftByY
.import ShiftZpXRightByY

.segment "kernal"

ssd1306_buffer = $7000 ; page-aligned 512 byte buffer

; zero-page globals
ssd1306_ptr    = $A0
ssd1306_ptr_hi = $A1
font_ptr       = $A2
font_ptr_hi    = $A3

Main:
;--------

  ; Initialize pointer to an 8x8 screen segment.
  LDA #.LOBYTE(ssd1306_buffer)
  STA ssd1306_ptr
  LDA #.HIBYTE(ssd1306_buffer)
  STA ssd1306_ptr_hi

  JSR Ssd1306Init

  LDX #ssd1306_ptr
  LDY #16
BlankLineLoop:
  JSR SsdNextSegment
  DEY
  BNE BlankLineLoop

  LDX #font_ptr
  LDY #8 ; h
  JSR FontSelectChar
  JSR WriteLetter
  LDX #ssd1306_ptr
  JSR SsdNextSegment

  LDX #font_ptr
  LDY #5 ; e
  JSR FontSelectChar
  JSR WriteLetter
  LDX #ssd1306_ptr
  JSR SsdNextSegment

  LDX #font_ptr
  LDY #12 ; l
  JSR FontSelectChar
  JSR WriteLetter
  LDX #ssd1306_ptr
  JSR SsdNextSegment

  LDX #font_ptr
  LDY #12 ; l
  JSR FontSelectChar
  JSR WriteLetter
  LDX #ssd1306_ptr
  JSR SsdNextSegment

  LDX #font_ptr
  LDY #15 ; o
  JSR FontSelectChar
  JSR WriteLetter
  LDX #ssd1306_ptr
  JSR SsdNextSegment


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
; Overwrites $12, $14, $15.
WriteLetter:
  LDY #0 ; font y-coordinate (bit index); screen x-coordinate (byte index)
  STY $14
@eachByte:
  LDX #7 ; font x-coordinate (byte index); screen y-coordinate (bit index)
  STX $15
  LDA #0
  STA (ssd1306_ptr),Y   ; zero the byte
@eachBit:
  ; create font bit mask in tmp
  LDA #%10000000
  STA $12               ; store initial bitmask at $0012
  LDX #$12              ; store ptr to $12 in X
  LDY $14
  JSR ShiftZpXRightByY  ; right-shift value at X=$12 Y times.
  LDA $12               ; resulting bitmask in A
  LDY $15
  AND (font_ptr),Y      ; AND with font data
  BEQ @donePixel        ; branch if bit was clear
  ; create display bit mask in tmp
  LDA #1
  STA $12               ; store initial bitmask at $0012
  LDX #$12              ; store ptr to $12 in X
  LDY $15               ; screen-Y (font-X) into Y
  JSR ShiftZpXLeftByY   ; left-shift value at X=$12 Y times.
  LDA $12               ; resulting bitmask in A
  ; apply to ssd buffer
  LDY $14
  ORA (ssd1306_ptr),Y  ; OR with destination data
  STA (ssd1306_ptr),Y  ; Store in destination data.

@donePixel:

  LDX $15
  DEX
  STX $15
  CPX #$FF
  BNE @eachBit

  LDY $14
  INY
  STY $14
  CPY #7
  BNE @eachByte

  RTS
