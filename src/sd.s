; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.segment "kernal"

.export SdCardInit
.export SdCardRead
.export SdCardReset

; Subroutines
.import SpiByte
.import StackPop
.import StackPush

; BSS vars
.import SpiMaskClock
.import SpiMaskMiso
.import SpiMaskMosi
.import SpiPort

;----------------------------------------
; SD card on port A of 6522 VIA at $9000

via_base = $9000

sd_mask_clock = %00010000
sd_mask_mosi = %00100000
sd_mask_miso = %01000000
sd_mask_cs = %10000000
sd_port = via_base + $01 ; PA
sd_ddr = via_base + $03 ; DDRA

; Initialize the VIA controller for the SD card.
.PROC SdCardInit
  ; DDR
  LDA sd_ddr
  ORA #(sd_mask_cs | sd_mask_clock | sd_mask_mosi) ; output
  AND #<~(sd_mask_miso) ; input
  STA sd_ddr
  JSR csHigh  ; deselect
  ; clock low
  LDA #<~sd_mask_clock
  AND sd_port
  STA sd_port
  RTS
.ENDPROC

; SdCardRead reads a block from address zero into into a fixed address.
; TODO: arguments for block number and destination pointer.
.PROC SdCardRead
  TXA
  PHA
  TYA
  PHA
  JSR configureSpi
  JSR csLow

  LDX #17 ; READ_SINGLE_BLOCK (CMD17)
  JSR sdCardCommand ; expect 32-bit address on user stack
  ; TODO: check R1 == 0x00 (ready)

waitForDataBlock:
  LDX #$FF  ; MOSI high
  JSR SpiByte
  CPX #$FE
  BNE waitForDataBlock

  ; read first 256-byte page of 512-byte block
  LDY #0
readLoop:
  LDX #$FF  ; MOSI high
  JSR SpiByte
  TXA
  STA $6000,Y  ; TODO: accept a ptr, store there.
  INY
  BNE readLoop

  ; read second 256-byte page of 512-byte block
  LDY #0
readLoop2:
  LDX #$FF  ; MOSI high
  JSR SpiByte
  TXA
  STA $6100,Y  ; TODO: accept a ptr, store there.
  INY
  BNE readLoop2

  PLA
  TAY
  PLA
  TAX
  RTS
.ENDPROC

; Switch to SPI mode, expect R1 response.
.PROC SdCardReset
  TXA
  PHA
  JSR configureSpi
  JSR wasteClock
  JSR csLow

  LDX #0 ; GO_IDLE_STATE (CMD0); enter SPI mode.
  LDA #0
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR sdCardCommand
  ; TODO: check R1 == 0x01

sd_send_op_cond_loop:
  LDX #55 ; APP_CMD (CMD55)
  LDA #0
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR sdCardCommand
  ; TODO: check R1 == 0x01
  LDX #41 ; SD_SEND_OP_COND (ACMD41)
  LDA #0
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR StackPush
  JSR sdCardCommand
  CPX #0
  BNE sd_send_op_cond_loop

  JSR csHigh
  JSR wasteClock

  PLA
  TAX
  RTS
.ENDPROC

; Configure SPI driver parameters to use SD card.
.PROC configureSpi
  LDA #sd_mask_clock
  STA SpiMaskClock
  LDA #sd_mask_mosi
  STA SpiMaskMosi
  LDA #sd_mask_miso
  STA SpiMaskMiso
  LDA #.LOBYTE(sd_port)
  STA SpiPort
  LDA #.HIBYTE(sd_port)
  STA SpiPort + 1
  RTS
.ENDPROC

; wasteClock sends 80 clock cycles with CS high (disabled).
; This is necessary at startup (>= 74 SPI clocks), and after
; receiving a final response (>= NCR clock cycles).
.PROC wasteClock
  TYA
  PHA
  JSR csHigh
  LDY #10 ; 10 * 8 = 80 clocks
initDelayLoop:
  JSR SpiByte
  DEY
  BNE initDelayLoop
  PLA
  TAY
  RTS
.ENDPROC

; X: preserved
; Y: preserved
.PROC waitNotBusy
  TXA
  PHA
  TYA
  PHA
  LDY #8 ; Loop limit. Increase?
loop:
  LDX #$FF
  JSR SpiByte
  CPX #$FF
  BEQ done
  DEY
  BNE loop
timeout:
  ; TODO: indicate failure to caller.
done:
  PLA
  TAY
  PLA
  TAX
  RTS
.ENDPROC

; X in: CMD, e.g. 0 for CMD0
; X out: R1
; 4 byte argument popped from user stack MSByte first; push LSByte first.
.PROC sdCardCommand
  JSR csLow
  JSR waitNotBusy
  TXA
  AND #%00111111  ;
  ORA #%01000000  ; command is 01______
  TAX
  JSR SpiByte  ; CMD
  JSR StackPop
  TAX
  JSR SpiByte  ; arg
  JSR StackPop
  TAX
  JSR SpiByte  ; arg
  JSR StackPop
  TAX
  JSR SpiByte  ; arg
  JSR StackPop
  TAX
  JSR SpiByte  ; arg
  LDX #$95     ; static CRC + end bit for CMD0; ignored for other CMDs.
  JSR SpiByte  ; CRC
  JSR waitR1   ; X <- R1
  RTS
.ENDPROC

; X out: R1 response.
.PROC waitR1
loop:
  LDX #$FF
  JSR SpiByte
  TXA
  AND #$80 ; busy loop while MSB is high; valid r1 is 0_______.
  BNE loop
  RTS
.ENDPROC

; Read Y bytes of data, plus start-byte and CRC bytes.
; * First byte: Start Block.
; * Bytes 2-513 (depends on the data block length): User Data.
; * Last two bytes: 16-bit CRC.
.PROC readData
  TYA
  PHA
  JSR SpiByte ; read start block (11111110)
loop:
  JSR SpiByte ; data byte
  ; TODO: store byte somewhere?
  DEY
  BNE loop
  JSR SpiByte ; CRC
  JSR SpiByte ; CRC
  PLA
  TAY
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
; Note:
; The host must keep the clock running for at least
; NCR clock cycles after the card response is received.
.PROC checkR1Response
  RTS
.ENDPROC

.PROC csHigh
  LDA sd_port
  ORA #sd_mask_cs
  STA sd_port
  RTS
.ENDPROC

.PROC csLow
  LDA sd_port
  AND #<~sd_mask_cs
  STA sd_port
  RTS
.ENDPROC
