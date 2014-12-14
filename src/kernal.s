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

.segment "kernal"

Main:
;--------

  JMP Halt


Halt:
;--------
NOP
JMP Halt
