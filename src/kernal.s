; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main
.import Ssd1306Init
.import Ssd1306WriteScreen
.import SplashData

.segment "kernal"

Main:
;--------

  JSR Ssd1306Init

  ; Store pointer to data at $10
  LDA #.LOBYTE(SplashData)
  STA $10
  LDA #.HIBYTE(SplashData)
  STA $11

  JSR Ssd1306WriteScreen

Halt:
;--------
NOP
JMP Halt
