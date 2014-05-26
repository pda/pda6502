; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export Main

; timing
.import SleepXSeconds

; encoding
.import AsciiToPetscii

; ssd1306
.import Ssd1306Init
.import Ssd1306WriteScreen
.import SsdNextSegment
.import Ssd1306WriteCharacter

; font
.import FontSelectChar

; SD card
.import SdCardInit
.import SdCardRead
.import SdCardReset

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

  LDA #0
  STA $10 ; loop counter = 0
@writeLoop:
  LDX $10
  LDY Message,X              ; Y = ASCII-ish byte.
  JSR writeAsciiToSsdBuffer
  INC $10
  LDA $10
  CMP #message_length
  BNE @writeLoop

  LDX #.LOBYTE(ssd1306_buffer)
  LDY #.HIBYTE(ssd1306_buffer)
  JSR Ssd1306WriteScreen

  ;----------------------------------------

  LDX #1
  JSR SleepXSeconds

  JSR SdCardInit
  JSR SdCardReset
  JSR SdCardRead ; into $6000 for now.

  ; Initialize pointer to an 8x8 screen segment.
  LDA #.LOBYTE(ssd1306_buffer)
  STA ssd1306_ptr
  LDA #.HIBYTE(ssd1306_buffer)
  STA ssd1306_ptr_hi

  LDA #0
  STA $10 ; loop counter = 0
@writeLoop2:
  LDX $10
  LDY $6000,X              ; Y = ASCII-ish byte.
  JSR writeAsciiToSsdBuffer
  INC $10
  LDA $10
  CMP #message_length
  BNE @writeLoop2

  LDX #.LOBYTE(ssd1306_buffer)
  LDY #.HIBYTE(ssd1306_buffer)
  JSR Ssd1306WriteScreen

  ;----------------------------------------
  JMP Halt


Halt:
;--------
NOP
JMP Halt


; Y: ASCII-ish char to write.
; X: destroyed
.PROC writeAsciiToSsdBuffer
  JSR AsciiToPetscii         ; convert Y to PETSCII font offset.
  LDX #font_ptr
  JSR FontSelectChar         ; select character in font
  LDX #font_ptr
  LDY #ssd1306_ptr
  JSR Ssd1306WriteCharacter  ; write character to screen buffer
  LDX #ssd1306_ptr
  JSR SsdNextSegment         ; move to next screen buffer segment
  RTS
.ENDPROC

message_length = 64
Message:
  .byte 21, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 9
  .byte 2, " HELLO, WORLD!", 2
  .byte 2, "   PDA-6502   ", 2
  .byte 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 11
