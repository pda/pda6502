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

; ili9340
.import Ili9340Init
.import Ili9340Test

; fat
.import FatReadFile
.import FatSearchFilename

; font
.import FontSelectChar

; SD card
.import SdCardInit
.import SdCardRead
.import SdCardReset

; FAT filesystem
.import FatInit

; user-stack
.import StackPush

.segment "kernal"

ssd1306_buffer = $7000 ; page-aligned 512 byte buffer

; zero-page globals
ssd1306_ptr    = $A0
ssd1306_ptr_hi = $A1
font_ptr       = $A2
font_ptr_hi    = $A3

Main:
;--------

;  ; Initialize SSD1306 display.
;  JSR Ssd1306Init
;
;  JSR loadSplashScreen
;  JSR displayText
;
;  ; Initialize SD card
;  JSR SdCardInit
;  JSR SdCardReset
;
;  JSR FatInit
;
;  LDX #0
;filenameLoop:
;  LDA SplashFilename,X
;  STA FatSearchFilename,X
;  INX
;  CPX #11
;  BNE filenameLoop
;  JSR FatReadFile
;
;  JSR displayText

  JSR Ili9340Init
  JSR Ili9340Test

  JMP Halt


Halt:
;--------
NOP
JMP Halt

; Copy Message to $6000 for displayText
.PROC loadSplashScreen
  LDX #0
loop:
  CPX #message_length
  BEQ done
  LDA Message,X   ; A <- ASCII-ish byte from Message.
  STA $6000,X     ; $6000 <- A
  INX
  JMP loop
done:
  RTS
.ENDPROC

; Display the text at $6000
.PROC displayText
  ; Initialize pointer to an 8x8 screen segment.
  LDA #.LOBYTE(ssd1306_buffer)
  STA ssd1306_ptr
  LDA #.HIBYTE(ssd1306_buffer)
  STA ssd1306_ptr_hi

  LDA #0
  STA $10 ; loop counter = 0
loop:
  LDX $10
  LDY $6000,X              ; Y = ASCII-ish byte.
  JSR writeAsciiToSsdBuffer
  INC $10
  LDA $10
  CMP #message_length
  BNE loop

  LDX #.LOBYTE(ssd1306_buffer)
  LDY #.HIBYTE(ssd1306_buffer)
  JSR Ssd1306WriteScreen
  RTS
.ENDPROC

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

SplashFilename: .byte "SPLASH  TXT"

message_length = 64
Message:
  .byte 21, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 9
  .byte 2, "PDA6502 READY ", 2
  .byte 2, "RAM:32K ROM:8K", 2
  .byte 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 11
