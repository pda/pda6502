; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main
.import Ssd1306Init
.import Ssd1306WriteScreen
.import SplashData
.import CopyPages

.segment "kernal"

ssd1306_buffer = $7000 ; page-aligned 512 byte buffer

Main:
;--------

; Copy SplashData (ROM) to ssd1306_buffer (RAM).

  ; source pointer
  LDA #.LOBYTE(SplashData)
  STA $10
  LDA #.HIBYTE(SplashData)
  STA $11

  ; destination pointer
  LDA #.LOBYTE(ssd1306_buffer)
  STA $12
  LDA #.HIBYTE(ssd1306_buffer)
  STA $13

  LDX #2 ; move two pages of data
  JSR CopyPages

  JSR Ssd1306Init

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
