; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main

; ILI9340 display
.import Ili9340Init
.import Ili9340Test

; FAT filesystem
.import FatInit
.import FatReadFile
.import FatSearchFilename

; SD card
.import SdCardInit
.import SdCardRead
.import SdCardReset

; Sleep
.import SleepXMs

.segment "kernal"

Main:
;--------

  JMP Halt


Halt:
;--------
NOP
JMP Halt


; Debugging: blink entire port A; 100ms on, 100ms off.
.PROC blinkOnce
  LDA #$FF
  STA $9003 ; port A DDR; all output
  STA $9001 ; port A; all on.
  LDX #200
  JSR SleepXMs
  LDA #0
  STA $9001 ; port A; all off.
  LDX #200
  JSR SleepXMs
  RTS
.ENDPROC
