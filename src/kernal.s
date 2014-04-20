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

  ; PCR (Peripheral Control Register)
  ; CB2: pulse output
  ; CA2: pulse output
  LDX #%10101010
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
  SSD1306_LCDHEIGHT = 32
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

  ; Reset (high, low, high).
  ; Okay to overwrite other pins for now.
  LDA #ssd_mask_reset
  STA ssd_port         ; reset high (inactive)
  JSR SleepOneMs       ; 1 ms
  LDA #%00000000
  STA ssd_port         ; reset low (active)
  LDX #10
  JSR SleepXMs         ; 10 ms
  LDA #ssd_mask_reset
  STA ssd_port         ; reset high (inactive)

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

  LDX #SSD1306_INVERTDISPLAY
  JSR SsdCommand

  ;;;
  ; Write screen
SsdWriteScreen:

  ; Reset some things.
  LDX #(SSD1306_SETLOWCOLUMN | $0)  ; low col = 0
  JSR SsdCommand
  LDX #(SSD1306_SETHIGHCOLUMN | $0)  ; hi col = 0
  JSR SsdCommand
  LDX #(SSD1306_SETSTARTLINE | $0)  ; line #0
  JSR SsdCommand

  ; D/C: high
  LDA #ssd_mask_dc
  ORA ssd_port
  STA ssd_port

  ; Write (SSD1306_LCDWIDTH * SSD1306_LCDHEIGHT / 8) bytes via SPI.

  ; Store pointer to data at $10
  LDA #.LOBYTE(SplashData)
  STA $10
  LDA #.HIBYTE(SplashData)
  STA $11

  LDA #2 ; loop for two 256-byte pages
  PHA      ; store page counter
@eachPage:
  LDY #$00
@eachByte:
  LDA ($10),Y
  TAX
  JSR SpiWrite
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
  JSR SpiWrite
  INY
  BNE SsdWriteZeroLoop2
  LDX #$00 ; data
  LDY #$00 ; loop index
SsdWriteZeroLoop3:
  JSR SpiWrite
  INY
  BNE SsdWriteZeroLoop3

End:
  JMP Halt

; X: command data
SsdCommand:

  ; DC = low
  LDA #ssd_mask_dc
  EOR #$FF
  AND ssd_port
  STA ssd_port

  JSR SpiWrite

  RTS

; X: command data
; Y: (preserved)
; A: (preserved)
; $10: (preserved)
SpiWrite:
  PHA
  TYA
  PHA
  LDA $10
  PHA

  LDY #%10000000
@eachBit:

  ; clock low
  LDA #ssd_mask_clock
  EOR #$FF
  AND ssd_port
  STA ssd_port

  ; write data bit
  TXA
  STY $10
  AND $10
  BEQ @prepareLow
@prepareHigh:
  LDA #ssd_mask_data
  ORA ssd_port
  JMP @writeData
@prepareLow:
  LDA #ssd_mask_data
  EOR #$FF
  AND ssd_port
@writeData:
  STA ssd_port

  ; clock high
  LDA #ssd_mask_clock
  ORA ssd_port
  STA ssd_port

  TYA
  LSR ; shift to next bit (or zero)
  TAY
  BNE @eachBit

  PLA
  STA $10
  PLA
  TAY
  PLA
  RTS

; Sleep for X milliseconds (assuming 1 MHz).
SleepXMs:
  TXA
  PHA
@loop:
  JSR SleepOneMs
  DEX
  BNE @loop
  PLA
  TAX
  RTS

; Sleep for 196*5=1280 (plus about 20) cycles == ~1 ms at 1 MHz
SleepOneMs:
  TXA
  PHA
  LDX #196
@loop:
  DEX         ; 2 cycles
  BNE @loop   ; 3 cycles (+2 if branching to new page)
  PLA
  TAX
  RTS

Halt:
;--------
NOP
JMP Halt

; Data
;-----

Message: .byte "Hello pda6502", $0A, $00

SplashData:
;---------
; Splash screen data from Adafruit_SSD1306.cpp
; 128x32 pixels, 512 bytes.
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80
.byte $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $80, $80, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $80, $C0, $E0, $F0, $F8, $FC, $F8, $E0, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $80
.byte $80, $80, $00, $80, $80, $00, $00, $00, $00, $80, $80, $80, $80, $80, $00, $FF
.byte $FF, $FF, $00, $00, $00, $00, $80, $80, $80, $80, $00, $00, $80, $80, $00, $00
.byte $80, $FF, $FF, $80, $80, $00, $80, $80, $00, $80, $80, $80, $80, $00, $80, $80
.byte $00, $00, $00, $00, $00, $80, $80, $00, $00, $8C, $8E, $84, $00, $00, $80, $F8
.byte $F8, $F8, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $E0, $E0, $C0, $80
.byte $00, $E0, $FC, $FE, $FF, $FF, $FF, $7F, $FF, $FF, $FF, $FF, $FF, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $C7, $01, $01
.byte $01, $01, $83, $FF, $FF, $00, $00, $7C, $FE, $C7, $01, $01, $01, $01, $83, $FF
.byte $FF, $FF, $00, $38, $FE, $C7, $83, $01, $01, $01, $83, $C7, $FF, $FF, $00, $00
.byte $01, $FF, $FF, $01, $01, $00, $FF, $FF, $07, $01, $01, $01, $00, $00, $7F, $FF
.byte $80, $00, $00, $00, $FF, $FF, $7F, $00, $00, $FF, $FF, $FF, $00, $00, $01, $FF
.byte $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $03, $0F, $3F, $7F, $7F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $E7, $C7, $C7, $8F
.byte $8F, $9F, $BF, $FF, $FF, $C3, $C0, $F0, $FF, $FF, $FF, $FF, $FF, $FC, $FC, $FC
.byte $FC, $FC, $FC, $FC, $FC, $F8, $F8, $F0, $F0, $E0, $C0, $00, $01, $03, $03, $03
.byte $03, $03, $01, $03, $03, $00, $00, $00, $00, $01, $03, $03, $03, $03, $01, $01
.byte $03, $01, $00, $00, $00, $01, $03, $03, $03, $03, $01, $01, $03, $03, $00, $00
.byte $00, $03, $03, $00, $00, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $01
.byte $03, $03, $03, $03, $03, $01, $00, $00, $00, $01, $03, $01, $00, $00, $00, $03
.byte $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
