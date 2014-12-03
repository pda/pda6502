; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

; ILI9340 240x320 RGB TFT display, connected to 6522 VIA.
; http://www.adafruit.com/products/1480
; Code inspired by / ported from https://github.com/adafruit/Adafruit_ILI9340

.export Ili9340Init
.export Ili9340Test

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
.import SpiByteReadPortB

.segment "kernal"

via_base = $C000
via_port = via_base + $00 ; PB
via_ddr  = via_base + $02 ; DDRB

offset_x = 60
offset_y = 20
width  = 200
height = 200

; pin masks relative to VIA port
mask_clock = %00000001
mask_dc    = %00000100
mask_reset = %00001000
mask_cs    = %00100000
mask_mosi  = %01000000
mask_miso  = %10000000

; command constants
ILI9340_NOP        = $00
ILI9340_SWRESET    = $01
ILI9340_RDDID      = $04
ILI9340_RDDST      = $09
ILI9340_SLPIN      = $10 ; enter sleep
ILI9340_SLPOUT     = $11 ; exit sleep
ILI9340_PTLON      = $12
ILI9340_NORON      = $13
ILI9340_RDMODE     = $0A
ILI9340_RDMADCTL   = $0B
ILI9340_RDPIXFMT   = $0C
ILI9340_RDIMGFMT   = $0A
ILI9340_RDSELFDIAG = $0F
ILI9340_INVOFF     = $20
ILI9340_INVON      = $21
ILI9340_GAMMASET   = $26 ; gamma curve selected
ILI9340_DISPOFF    = $28 ; display off
ILI9340_DISPON     = $29 ; display on
ILI9340_CASET      = $2A ; column address set
ILI9340_PASET      = $2B ; row address set
ILI9340_RAMWR      = $2C ; write to RAM
ILI9340_RAMRD      = $2E
ILI9340_PTLAR      = $30
ILI9340_MADCTL     = $36 ; memory access control
ILI9340_MADCTL_MY  = $80
ILI9340_MADCTL_MX  = $40
ILI9340_MADCTL_MV  = $20
ILI9340_MADCTL_ML  = $10
ILI9340_MADCTL_RGB = $00
ILI9340_MADCTL_BGR = $08
ILI9340_MADCTL_MH  = $04
ILI9340_PIXFMT     = $3A
ILI9340_FRMCTR1    = $B1
ILI9340_FRMCTR2    = $B2
ILI9340_FRMCTR3    = $B3
ILI9340_INVCTR     = $B4
ILI9340_DFUNCTR    = $B6 ; display function control
ILI9340_PWCTR1     = $C0 ; power control
ILI9340_PWCTR2     = $C1 ; power control
ILI9340_PWCTR3     = $C2
ILI9340_PWCTR4     = $C3
ILI9340_PWCTR5     = $C4
ILI9340_VMCTR1     = $C5 ; VCM control
ILI9340_VMCTR2     = $C7 ; VCM control
ILI9340_RDID1      = $DA
ILI9340_RDID2      = $DB
ILI9340_RDID3      = $DC
ILI9340_RDID4      = $DD
ILI9340_GMCTRP1    = $E0 ; set gamma
ILI9340_GMCTRN1    = $E1 ; set gamma

; color constants
C_BLACK   = $0000
C_BLUE    = $001F
C_RED     = $F800
C_GREEN   = $07E0
C_CYAN    = $07FF
C_MAGENTA = $F81F
C_YELLOW  = $FFE0
C_WHITE   = $FFFF


.PROC Ili9340Init
  JSR configureDataDirection
  JSR configureSpi
  JSR reset
  JSR initializationCommands
  JSR initializeRotation
  RTS
.ENDPROC

.PROC Ili9340Test
  JSR spiSelect
  JSR setFullScreen
  JSR dataMode
  LDA #width
  BEQ done
  STA $20
  LDA #height
  BEQ done
  STA $21
loop:
  LDX $21
  JSR SpiByteReadPortB
  LDX $20
  JSR SpiByteReadPortB
  DEC $20     ; go to next column.
  BNE loop    ; if more columns, loop,
  LDA #width  ; else reset column counter..
  STA $20
  DEC $21     ; .. and go to next row.
  BNE loop    ; if more rows loop.
done:
  JSR spiDeselect
  RTS
.ENDPROC

.PROC configureDataDirection
  LDA via_ddr
  ORA #(mask_clock | mask_dc | mask_reset | mask_cs | mask_mosi) ; output
  AND #<~(mask_miso) ; input
  STA via_ddr
  RTS
.ENDPROC

; Configure SPI driver parameters to use SSD1306 display.
.PROC configureSpi
  LDA #mask_clock
  STA SpiMaskClock
  LDA #mask_mosi
  STA SpiMaskMosi
  LDA #mask_miso
  STA SpiMaskMiso
  LDA #.LOBYTE(via_port)
  STA SpiPort
  LDA #.HIBYTE(via_port)
  STA SpiPort + 1
  RTS
.ENDPROC

.PROC reset
  LDA via_port
  ORA #(mask_cs | mask_reset)    ; initialize high
  AND #<~(mask_clock | mask_mosi) ; initialize low
  STA via_port
  JSR SleepOneMs
  LDA via_port
  AND #<~mask_reset ; assert reset
  STA via_port
  JSR SleepOneMs   ; data sheet says hold at least 10 uS.
  LDA via_port
  ORA #mask_reset  ; release reset
  STA via_port
  LDX #10          ; data sheet says wait at least 5msec after releasing reset.
  JSR SleepXMs
  RTS
.ENDPROC

.PROC initializationCommands
  JSR spiSelect
  JSR commandMode
  LDX #$EF
  JSR SpiByte
  JSR dataMode
  LDX #$03
  JSR SpiByte
  LDX #$80
  JSR SpiByte
  LDX #$02
  JSR SpiByte

  JSR commandMode
  LDX #$CF
  JSR SpiByte
  JSR dataMode
  LDX #$00
  JSR SpiByte
  LDX #$C1
  JSR SpiByte
  LDX #$30
  JSR SpiByte

  JSR commandMode
  LDX #$ED
  JSR SpiByte
  JSR dataMode
  LDX #$64
  JSR SpiByte
  LDX #$03
  JSR SpiByte
  LDX #$12
  JSR SpiByte
  LDX #$81
  JSR SpiByte

  JSR commandMode
  LDX #$E8
  JSR SpiByte
  JSR dataMode
  LDX #$85
  JSR SpiByte
  LDX #$00
  JSR SpiByte
  LDX #$78
  JSR SpiByte

  JSR commandMode
  LDX #$CB
  JSR SpiByte
  JSR dataMode
  LDX #$39
  JSR SpiByte
  LDX #$2C
  JSR SpiByte
  LDX #$00
  JSR SpiByte
  LDX #$34
  JSR SpiByte
  LDX #$02
  JSR SpiByte

  JSR commandMode
  LDX #$F7
  JSR SpiByte
  JSR dataMode
  LDX #$20
  JSR SpiByte

  JSR commandMode
  LDX #$EA
  JSR SpiByte
  JSR dataMode
  LDX #$00
  JSR SpiByte
  LDX #$00
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_PWCTR1
  JSR SpiByte
  JSR dataMode
  LDX #$23
  JSR SpiByte   ; VRH[5:0]

  JSR commandMode
  LDX #ILI9340_PWCTR2
  JSR SpiByte
  JSR dataMode
  LDX #$10
  JSR SpiByte   ; SAP[2:0];BT[3:0]

  JSR commandMode
  LDX #ILI9340_VMCTR1
  JSR SpiByte
  JSR dataMode
  LDX #$3e
  JSR SpiByte
  LDX #$28
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_VMCTR2
  JSR SpiByte
  JSR dataMode
  LDX #$86
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_MADCTL
  JSR SpiByte
  JSR dataMode
  LDX #ILI9340_MADCTL_MX | ILI9340_MADCTL_BGR
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_PIXFMT
  JSR SpiByte
  JSR dataMode
  LDX #$55
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_FRMCTR1
  JSR SpiByte
  JSR dataMode
  LDX #$00
  JSR SpiByte
  LDX #$18
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_DFUNCTR
  JSR SpiByte
  JSR dataMode
  LDX #$08
  JSR SpiByte
  LDX #$82
  JSR SpiByte
  LDX #$27
  JSR SpiByte

  JSR commandMode
  LDX #$F2    ;  3Gamma Function Disable
  JSR SpiByte
  JSR dataMode
  LDX #$00
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_GAMMASET
  JSR SpiByte
  JSR dataMode
  LDX #$01
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_GMCTRP1
  JSR SpiByte
  JSR dataMode
  LDX #$0F
  JSR SpiByte
  LDX #$31
  JSR SpiByte
  LDX #$2B
  JSR SpiByte
  LDX #$0C
  JSR SpiByte
  LDX #$0E
  JSR SpiByte
  LDX #$08
  JSR SpiByte
  LDX #$4E
  JSR SpiByte
  LDX #$F1
  JSR SpiByte
  LDX #$37
  JSR SpiByte
  LDX #$07
  JSR SpiByte
  LDX #$10
  JSR SpiByte
  LDX #$03
  JSR SpiByte
  LDX #$0E
  JSR SpiByte
  LDX #$09
  JSR SpiByte
  LDX #$00
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_GMCTRN1
  JSR SpiByte
  JSR dataMode
  LDX #$00
  JSR SpiByte
  LDX #$0E
  JSR SpiByte
  LDX #$14
  JSR SpiByte
  LDX #$03
  JSR SpiByte
  LDX #$11
  JSR SpiByte
  LDX #$07
  JSR SpiByte
  LDX #$31
  JSR SpiByte
  LDX #$C1
  JSR SpiByte
  LDX #$48
  JSR SpiByte
  LDX #$08
  JSR SpiByte
  LDX #$0F
  JSR SpiByte
  LDX #$0C
  JSR SpiByte
  LDX #$31
  JSR SpiByte
  LDX #$36
  JSR SpiByte
  LDX #$0F
  JSR SpiByte

  JSR commandMode
  LDX #ILI9340_SLPOUT
  JSR SpiByte
  LDX 120
  JSR SleepXMs
  LDX #ILI9340_DISPON
  JSR SpiByte

  JSR spiDeselect
  RTS
.ENDPROC

.PROC initializeRotation
  JSR spiSelect
  JSR commandMode
  LDX #ILI9340_MADCTL
  JSR SpiByte
  JSR dataMode
  LDX #(ILI9340_MADCTL_MV | ILI9340_MADCTL_BGR)
  JSR SpiByte
  JSR spiDeselect
  RTS
.ENDPROC

.PROC commandMode
  LDA via_port
  AND #<~mask_dc ; D/C low: command mode
  STA via_port
  RTS
.ENDPROC

.PROC dataMode
  LDA via_port
  ORA #mask_dc ; D/C high: data mode
  STA via_port
  RTS
.ENDPROC

.PROC spiDeselect
  LDA via_port
  ORA #mask_cs
  STA via_port
  RTS
.ENDPROC

.PROC spiSelect
  LDA via_port
  AND #<~mask_cs
  STA via_port
  RTS
.ENDPROC

.PROC setFullScreen
  JSR commandMode
  ; set column address:
  LDX #ILI9340_CASET
  JSR SpiByte
  JSR dataMode
  ; set x0
  LDX #.HIBYTE(offset_x)
  JSR SpiByte
  LDX #.LOBYTE(offset_x)
  JSR SpiByte
  ; set x1
  LDX #.HIBYTE(offset_x + width - 1)
  JSR SpiByte
  LDX #.LOBYTE(offset_x + width - 1)
  JSR SpiByte
  JSR commandMode
  ; set row address:
  LDX #ILI9340_PASET
  JSR SpiByte
  JSR dataMode
  ; set y0
  LDX #.HIBYTE(offset_y)
  JSR SpiByte
  LDX #.LOBYTE(offset_y)
  JSR SpiByte
  ; set y1
  LDX #.HIBYTE(offset_y + height - 1)
  JSR SpiByte
  LDX #.LOBYTE(offset_y + height - 1)
  JSR SpiByte
  JSR commandMode
  ; set write to RAM
  LDX #ILI9340_RAMWR
  JSR SpiByte
  RTS
.ENDPROC
