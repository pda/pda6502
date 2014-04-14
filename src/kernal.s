; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

;--------------------
.segment "vectors"

; $FFFA: NMIB
.word NonMaskableInterrupt

; $FFFC: RESB
.word ColdStart

; $FFFE: BRK/IRQB
.word Interrupt

;--------------------
.segment "kernal"

ColdStart:
;--------
SEI          ; mask interrupts during start-up
LDX #$FF     ;
TXS          ; set stack pointer to $ff ($01FF)
CLI          ; resume interrupts
CLD          ; don't be in crazy decimal mode.
JMP Main

Interrupt:
;--------
RTI

NonMaskableInterrupt:
;--------
RTI

Main:
;--------

  ;;; VIA at $C000

  via_base = $C000
  via_pcr  = via_base + $0C

  ; CA2 handshake: pulse output (for logic analyzer)
  LDX #$0A
  STX via_pcr

  ; SSD1306 128x32 OLED on VIA port A.
  ; SSD1306 DDR at $C003; 1 == output, 0 == input.

  ssd_port = via_base + $01
  ssd_ddr  = via_base + $03

  ssd_mask_reset = %00001000
  ssd_mask_dc    = %00000100
  ssd_mask_clock = %00000010
  ssd_mask_data  = %00000001

  SSD1306_LCDWIDTH = 128
  SSD1306_LCDHEIGHT = 64
  SSD1306_SETCONTRAST = $81
  SSD1306_DISPLAYALLON_RESUME = $A4
  SSD1306_DISPLAYALLON = $A5
  SSD1306_NORMALDISPLAY = $A6
  SSD1306_INVERTDISPLAY = $A7
  SSD1306_DISPLAYOFF = $AE
  SSD1306_DISPLAYON = $AF
  SSD1306_SETDISPLAYOFFSET = $D3
  SSD1306_SETCOMPINS = $DA
  SSD1306_SETVCOMDETECT = $DB
  SSD1306_SETDISPLAYCLOCKDIV = $D5
  SSD1306_SETPRECHARGE = $D9
  SSD1306_SETMULTIPLEX = $A8
  SSD1306_SETLOWCOLUMN = $00
  SSD1306_SETHIGHCOLUMN = $10
  SSD1306_SETSTARTLINE = $40
  SSD1306_MEMORYMODE = $20
  SSD1306_COMSCANINC = $C0
  SSD1306_COMSCANDEC = $C8
  SSD1306_SEGREMAP = $A0
  SSD1306_CHARGEPUMP = $8D
  SSD1306_EXTERNALVCC = $1
  SSD1306_SWITCHCAPVCC = $2

  ; Data direction output for all pins.
  LDX #$FF
  STX ssd_ddr

  ; Reset (high, low, high). Hope this is slow enough.
  ; Okay to overwrite other pins for now.
  LDA #ssd_mask_reset
  STA ssd_port
  LDA #%00000000
  STA ssd_port
  LDA #ssd_mask_reset
  STA ssd_port

  ; SSD1306 128x32 init lifted from adafruit C++ code.

  LDX #SSD1306_DISPLAYOFF
  JSR SsdCommand

  LDX #SSD1306_SETDISPLAYCLOCKDIV
  JSR SsdCommand
  LDX #$80
  JSR SsdCommand

  LDX #SSD1306_SETMULTIPLEX
  JSR SsdCommand
  LDX #$1F
  JSR SsdCommand

  LDX #SSD1306_SETDISPLAYOFFSET
  JSR SsdCommand
  LDX #$00
  JSR SsdCommand

  LDX #(SSD1306_SETSTARTLINE | $00) ; line 0
  JSR SsdCommand

  LDX #SSD1306_CHARGEPUMP
  JSR SsdCommand
  LDX #$14 ; related to SSD1306_SWITCHCAPVCC?
  JSR SsdCommand

  LDX #SSD1306_MEMORYMODE
  JSR SsdCommand
  LDX #$00 ; "like ks0108"?
  JSR SsdCommand

  LDX #(SSD1306_SEGREMAP | $01)
  JSR SsdCommand

  LDX #SSD1306_COMSCANDEC
  JSR SsdCommand

  LDX #SSD1306_SETCOMPINS
  JSR SsdCommand
  LDX #$02
  JSR SsdCommand

  LDX #SSD1306_SETCONTRAST
  JSR SsdCommand
  LDX #$8F
  JSR SsdCommand

  LDX #SSD1306_SETPRECHARGE
  JSR SsdCommand
  LDX #$F1 ; related to SSD1306_SWITCHCAPVCC
  JSR SsdCommand

  LDX #SSD1306_SETVCOMDETECT
  JSR SsdCommand
  LDX #$40
  JSR SsdCommand

  LDX #SSD1306_DISPLAYALLON_RESUME
  JSR SsdCommand

  LDX #SSD1306_NORMALDISPLAY
  JSR SsdCommand

  LDX #SSD1306_DISPLAYON
  JSR SsdCommand

  ; Finished SSD1306 init.

BlargLoop:

  LDX #SSD1306_INVERTDISPLAY
  JSR SsdCommand

  LDX #SSD1306_NORMALDISPLAY
  JSR SsdCommand

  JMP BlargLoop

End:
  JMP Halt

; X: command data
SsdCommand:

  ; DC = low
  LDA #%00000100
  EOR #$FF
  AND ssd_port
  STA ssd_port

  JSR SpiWrite

  RTS

; X: command data
SpiWrite:
  LDY #%10000000
SpiWriteLoop:

  ; clock low
  LDA #ssd_mask_clock
  EOR #$FF
  AND ssd_port
  STA ssd_port

  ; write data bit
  TXA
  STY $10
  AND $10
  BEQ SpiPrepareLow
SpiPrepareHigh:
  LDA #ssd_mask_data
  ORA ssd_port
  JMP SpiWriteData
SpiPrepareLow:
  LDA #ssd_mask_data
  EOR #$FF
  AND ssd_port
SpiWriteData:
  STA ssd_port

  ; clock high
  LDA #ssd_mask_clock
  ORA ssd_port
  STA ssd_port

  TYA
  LSR ; shift to next bit (or zero)
  TAY
  BNE SpiWriteLoop

  RTS


Halt:
;--------
JMP Halt

; Data
;-----

Message: .byte "Hello pda6502", $0A, $00
