; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

; SSD1306 OLED display, connected to VIA6522.

.export Ssd1306Init
.export Ssd1306WriteScreen
.export SsdNextSegment
.export Ssd1306WriteCharacter

; BSS vars
.import SpiMaskClock
.import SpiMaskMiso
.import SpiMaskMosi
.import SpiPort

; sleep
.import SleepOneMs
.import SleepXMs

; spi
.import SpiByte

; bitwise
.import ShiftZpXLeftByY
.import ShiftZpXRightByY

.segment "kernal"

; MOS 6522 VIA parameters.
via_base = $C000
via_pcr  = via_base + $0C

; SSD1306 display parameters & wiring.
; TODO: make some or all of these dynamic, specified by caller.
ssd1306_lcdwidth    = 128
ssd1306_lcdheight   = 32
ssd1306_mask_reset  = %00001000
ssd1306_mask_dc     = %00000100
ssd1306_mask_clock  = %00000010
ssd1306_mask_data   = %00000001
ssd1306_port        = via_base + $00 ; PB
ssd1306_ddr         = via_base + $02 ; DDRB

; SSD1306 command constants
SSD1306_SETCONTRAST         = $81
SSD1306_DISPLAYALLON_RESUME = $A4
SSD1306_DISPLAYALLON        = $A5
SSD1306_NORMALDISPLAY       = $A6
SSD1306_INVERTDISPLAY       = $A7
SSD1306_DISPLAYOFF          = $AE
SSD1306_DISPLAYON           = $AF
SSD1306_SETDISPLAYOFFSET    = $D3
SSD1306_SETCOMPINS          = $DA
SSD1306_SETVCOMDETECT       = $DB
SSD1306_SETDISPLAYCLOCKDIV  = $D5
SSD1306_SETPRECHARGE        = $D9
SSD1306_SETMULTIPLEX        = $A8
SSD1306_SETLOWCOLUMN        = $00
SSD1306_SETHIGHCOLUMN       = $10
SSD1306_SETSTARTLINE        = $40
SSD1306_MEMORYMODE          = $20
SSD1306_COMSCANINC          = $C0
SSD1306_COMSCANDEC          = $C8
SSD1306_SEGREMAP            = $A0
SSD1306_CHARGEPUMP          = $8D
SSD1306_EXTERNALVCC         = $01
SSD1306_SWITCHCAPVCC        = $02


; SSD1306 initialization.
; Mostly lifted from Adafruit's C++ arduino driver.
; Preserves A, X, Y.
Ssd1306Init:
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR configureSpi

  ; Data direction output for all pins.
  LDX #$FF
  STX ssd1306_ddr

  ; Reset (high, low, high).
  LDA #ssd1306_mask_reset
  STA ssd1306_port         ; reset high (inactive)
  JSR SleepOneMs       ; 1 ms
  LDA #%00000000
  STA ssd1306_port         ; reset low (active)
  LDX #10
  JSR SleepXMs         ; 10 ms
  LDA #ssd1306_mask_reset
  STA ssd1306_port         ; reset high (inactive)

  LDX #SSD1306_DISPLAYOFF
  JSR Ssd1306Command

  LDX #SSD1306_SETDISPLAYCLOCKDIV
  JSR Ssd1306Command
  LDX #$80
  JSR Ssd1306Command

  LDX #SSD1306_SETMULTIPLEX
  JSR Ssd1306Command
  LDX #$1F
  JSR Ssd1306Command

  LDX #SSD1306_SETDISPLAYOFFSET
  JSR Ssd1306Command
  LDX #$00
  JSR Ssd1306Command

  LDX #(SSD1306_SETSTARTLINE | $00) ; line 0
  JSR Ssd1306Command

  LDX #SSD1306_CHARGEPUMP
  JSR Ssd1306Command
  LDX #$14 ; related to SSD1306_SWITCHCAPVCC?
  JSR Ssd1306Command

  LDX #SSD1306_MEMORYMODE
  JSR Ssd1306Command
  LDX #$00 ; "like ks0108"?
  JSR Ssd1306Command

  LDX #(SSD1306_SEGREMAP | $01)
  JSR Ssd1306Command

  LDX #SSD1306_COMSCANDEC
  JSR Ssd1306Command

  LDX #SSD1306_SETCOMPINS
  JSR Ssd1306Command
  LDX #$02
  JSR Ssd1306Command

  LDX #SSD1306_SETCONTRAST
  JSR Ssd1306Command
  LDX #$8F
  JSR Ssd1306Command

  LDX #SSD1306_SETPRECHARGE
  JSR Ssd1306Command
  LDX #$F1 ; related to SSD1306_SWITCHCAPVCC
  JSR Ssd1306Command

  LDX #SSD1306_SETVCOMDETECT
  JSR Ssd1306Command
  LDX #$40
  JSR Ssd1306Command

  LDX #SSD1306_DISPLAYALLON_RESUME
  JSR Ssd1306Command

  LDX #SSD1306_NORMALDISPLAY
  JSR Ssd1306Command

  LDX #SSD1306_DISPLAYON
  JSR Ssd1306Command

  PLA
  TAY
  PLA
  TAX
  PLA

  RTS


; Write data to SSD1306 display.
; X,Y is 16-bit pointer to the data. Both are destroyed.
Ssd1306WriteScreen:
  LDA $10
  PHA
  LDA $11
  PHA

  JSR configureSpi

  ; Store data buffer ptr at $10
  STX $10
  STY $11

  ; Reset some things.
  LDX #(SSD1306_SETLOWCOLUMN | $0)  ; low col = 0
  JSR Ssd1306Command
  LDX #(SSD1306_SETHIGHCOLUMN | $0)  ; hi col = 0
  JSR Ssd1306Command
  LDX #(SSD1306_SETSTARTLINE | $0)  ; line #0
  JSR Ssd1306Command

  ; D/C: high
  LDA #ssd1306_mask_dc
  ORA ssd1306_port
  STA ssd1306_port

  ; Write (ssd1306_lcdwidth * ssd1306_lcdheight / 8) bytes via SPI.

  LDA #2 ; loop for two 256-byte pages
  PHA      ; store page counter
@eachPage:
  LDY #$00
@eachByte:
  LDA ($10),Y
  TAX
  JSR SpiByte
  TYA
  CMP #$FF ; 256 byte page written
  BEQ @donePage
  INY
  JMP @eachByte
@donePage:
  PLA
  TAX ; restore page counter
  DEX
  BEQ @donePages
  TXA
  PHA ; re-save page counter
  INC $11 ; next segment of data
  JMP @eachPage
@donePages:

  ; Ghetto writing of more zeros to fill 128x64 pixels.
  ; Adafruit code says: "i wonder why we have to do this (check datasheet)"
  ; (probably resets data pointer to zero; must be a better way)
  LDX #$00 ; data
  LDY #$00 ; loop index
SsdWriteZeroLoop2:
  JSR SpiByte
  INY
  BNE SsdWriteZeroLoop2
  LDX #$00 ; data
  LDY #$00 ; loop index
SsdWriteZeroLoop3:
  JSR SpiByte
  INY
  BNE SsdWriteZeroLoop3

  PLA
  STA $11
  PLA
  STA $10
  RTS


; Send a byte to SSD1306 in command mode.
; Ensures SSD1306's D/C is in command mode.
; X: command data
Ssd1306Command:
  PHA
  LDA #ssd1306_mask_dc ; Enable command mode.
  EOR #$FF
  AND ssd1306_port
  STA ssd1306_port
  JSR SpiByte ; Send byte in X.
  PLA
  RTS


; X: zero-page address of pointer
SsdNextSegment:
  JSR configureSpi
  CLC
  LDA 0,X
  ADC #8
  STA 0,X
  BCC @done
  INC 1,X
@done:
  RTS

; Write a character to the screen buffer.
; X: font_ptr
; Y: ssd1306_ptr
.PROC Ssd1306WriteCharacter

  font_ptr       = $10
  font_ptr_hi    = $11
  ssd1306_ptr    = $12
  ssd1306_ptr_hi = $13
  screen_x       = $14
  screen_y       = $15
  tmp_bitmask    = $16

  TXA
  PHA
  TYA
  PHA
  LDA font_ptr
  PHA
  LDA font_ptr_hi
  PHA
  LDA ssd1306_ptr
  PHA
  LDA ssd1306_ptr_hi
  PHA
  LDA screen_x
  PHA
  LDA screen_y
  PHA
  LDA tmp_bitmask
  PHA

  JSR configureSpi

  ; copy pointer to font to $10
  LDA 0,X
  STA font_ptr
  LDA 1,X
  STA font_ptr_hi

  ; copy pointer to screen buffer to $12
  TYA
  TAX
  LDA 0,X
  STA ssd1306_ptr
  LDA 1,X
  STA ssd1306_ptr_hi

  LDY #0 ; font y-coordinate (bit index); screen x-coordinate (byte index)
  STY screen_x
@eachByte:
  LDX #7 ; font x-coordinate (byte index); screen y-coordinate (bit index)
  STX screen_y
  LDA #0
  STA (ssd1306_ptr),Y   ; zero the byte
@eachBit:
  ; create font bit mask in tmp
  LDA #%10000000
  STA tmp_bitmask
  LDX #tmp_bitmask              ; store bitmask address in X
  LDY screen_x
  JSR ShiftZpXRightByY          ; right-shift value at X=tmp_bitmask Y times.
  LDA tmp_bitmask               ; resulting bitmask in A
  LDY screen_y
  AND (font_ptr),Y              ; AND with font data
  BEQ @donePixel                ; branch if bit was clear
  ; create display bit mask in tmp
  LDA #1
  STA tmp_bitmask               ; store initial bitmask at $0012
  LDX #tmp_bitmask              ; store ptr to $12 in X
  LDY screen_y                  ; screen-Y (font-X) into Y
  JSR ShiftZpXLeftByY           ; left-shift value at X=$12 Y times.
  LDA tmp_bitmask               ; resulting bitmask in A
  ; apply to ssd buffer
  LDY screen_x
  ORA (ssd1306_ptr),Y           ; OR with destination data
  STA (ssd1306_ptr),Y           ; Store in destination data.
@donePixel:
  LDX screen_y
  DEX
  STX screen_y
  CPX #$FF
  BNE @eachBit
  LDY screen_x
  INY
  STY screen_x
  CPY #8
  BNE @eachByte

  PLA
  STA tmp_bitmask
  PLA
  STA screen_y
  PLA
  STA screen_x
  PLA
  STA ssd1306_ptr_hi
  PLA
  STA ssd1306_ptr
  PLA
  STA font_ptr_hi
  PLA
  STA font_ptr
  PLA
  TAY
  PLA
  TAX
  RTS
.ENDPROC

; Configure SPI driver parameters to use SSD1306 display.
.PROC configureSpi
  LDA #ssd1306_mask_clock
  STA SpiMaskClock
  LDA #ssd1306_mask_data
  STA SpiMaskMosi
  LDA #ssd1306_mask_data ; (SSD1306 SPI has no MISO)
  STA SpiMaskMiso
  LDA #.LOBYTE(ssd1306_port)
  STA SpiPort
  LDA #.HIBYTE(ssd1306_port)
  STA SpiPort + 1
  RTS
.ENDPROC
