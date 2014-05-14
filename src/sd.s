; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.segment "kernal"

.export SdCardInit
.export SdCardReset

;----------------------------------------
; SD card on port A of 6522 VIA at $C000

via_base = $C000

sd_mask_cs = %10000000
sd_mask_clock = %01000000
sd_mask_miso = %00100000
sd_mask_mosi = %00010000
sd_port = via_base + $01 ; PA
sd_ddr = via_base + $03 ; DDRA

; Initialize the VIA controller for the SD card.
.PROC SdCardInit
  LDA sd_ddr
  ORA #(sd_mask_cs | sd_mask_clock | sd_mask_mosi) ; output
  AND #~(sd_mask_miso) ; input
  STA sd_ddr
  RTS
.ENDPROC

; Switch to SPI mode, expect R1 response.
.PROC SdCardReset
  TXA
  PHA

  LDA sd_port
  AND #~sd_mask_cs ; CS low (active)
  STA sd_port

  ; GO_IDLE_STATE (CMD0); enter SPI mode.
  LDX #$40
  JSR SpiWrite
  LDX #$00
  JSR SpiWrite
  LDX #$00
  JSR SpiWrite
  LDX #$00
  JSR SpiWrite
  LDX #$00
  JSR SpiWrite
  LDX #$95     ; static CRC + end bit for CMD0
  JSR SpiWrite

  JSR readR1Response

  ; TODO: SEND_OP_COND (CMD1)
  JSR readR1Response

  ; TODO: SET_BLOCKLEN (CMD16) arg: [31:0] block length
  JSR readR1Response

  ; TODO: READ_SINGLE_BLOCK (CMD17) arg: [31:0] data address
  JSR readR1Response
  ; TODO: read data into RAM
  ; TODO: read and ignore CRC for now.

  PLA
  TAX
  RTS
.ENDPROC


; TODO: read data into where?
; TODO: how many bytes to read?
; * First byte: Start Block.
; * Bytes 2-513 (depends on the data block length): User Data.
; * Last two bytes: 16-bit CRC.
.PROC readData

.ENDPROC

; R1 response: one-byte MSB-first. High bits indicate:
; 0: Idle state
; 1: Erase reset
; 2: Illegal command
; 3: Communication CRC error
; 4: Erase sequence error
; 5: Address error
; 6: Parameter error
; 7: (zero)
.PROC readR1Response
  JSR SpiRead
  RTS
.ENDPROC

; SpiRead reads a byte from MISO into X.
.PROC SpiRead
  RTS
.ENDPROC


; SpiWrite copied and modified from ssd1306 :(
; X: command data
; Y: (preserved)
; A: (preserved)
; $10: (preserved)
.PROC SpiWrite
  PHA
  TYA
  PHA
  LDA $10
  PHA

  LDY #%10000000
eachBit:

  ; clock low
  LDA #sd_mask_clock
  EOR #$FF
  AND sd_port
  STA sd_port

  ; write data bit
  TXA
  STY $10
  AND $10
  BEQ prepareLow
prepareHigh:
  LDA #sd_mask_mosi
  ORA sd_port
  JMP writeData
prepareLow:
  LDA #sd_mask_mosi
  EOR #$FF
  AND sd_port
writeData:
  STA sd_port

  ; clock high
  LDA #sd_mask_clock
  ORA sd_port
  STA sd_port

  TYA
  LSR ; shift to next bit (or zero)
  TAY
  BNE eachBit

  PLA
  STA $10
  PLA
  TAY
  PLA
  RTS
.ENDPROC ; SpiWrite
