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

; Status
.import BlinkOnce
.import HaltWithCodeX

.segment "kernal"

Main:
;--------

  JSR SdCardInit

  JSR SdCardReset

  JSR FatInit

  JSR fatSetFilename

  JSR FatReadFile

  JSR BlinkOnce

  JMP $1000 ; code loaded from SD card.


Halt:
;--------
NOP
JMP Halt


RomFilename: .byte "PDA6502 BIN"

.PROC fatSetFilename
  LDX #0
filenameLoop:
  LDA RomFilename,X
  STA FatSearchFilename,X
  INX
  CPX #11
  BNE filenameLoop
  RTS
.ENDPROC
