; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

; subroutines
.export SpiByte
.export SpiByteFastPortB

; BSS vars
.export SpiMaskClock
.export SpiMaskMiso
.export SpiMaskMosi
.export SpiPort

.segment "kernal_bss"

SpiMaskClock: .byte 0
SpiMaskMiso:  .byte 0
SpiMaskMosi:  .byte 0
SpiPort:      .word 0

.segment "kernal"

; SpiByte exchanges an output byte for an input byte via SPI.
; X: data input and output
; Y: (preserved)
; $10: (preserved) loop counter
; $12,$13: (preserved) SpiPort ptr
.PROC SpiByte
  TYA
  PHA
  LDA $10
  PHA
  LDA $12
  PHA
  LDA $13
  PHA

  LDA SpiPort
  STA $12
  LDA SpiPort + 1
  STA $13

  LDY #0 ; for ($12),Y (SpiPort ptr)

  LDA #8
  STA $10 ; count down 8 bits
eachBit:
  ; write MOSI
  TXA
  AND #(1 << 7) ; MSB
  BEQ writeZero
writeOne:
  LDA SpiMaskMosi
  ORA ($12),Y
  JMP write
writeZero:
  LDA SpiMaskMosi
  EOR #$FF
  LDY #0
  AND ($12),Y
write:
  STA ($12),Y

  TXA
  ASL ; push next most significant bit to front.
  TAX

  ; clock high
  LDA SpiMaskClock
  ORA ($12),Y
  STA ($12),Y

  ; read MISO
  LDA SpiMaskMiso
  AND ($12),Y
  BEQ readZero
readOne:
  TXA
  ORA #1
  JMP read
readZero:
  TXA
  AND #~1
read:
  TAX ; new bit set into x[0], which will be shifted left until byte read.

  ; clock low
  LDA SpiMaskClock
  EOR #$FF
  AND ($12),Y
  STA ($12),Y

  DEC $10
  BNE eachBit

  PLA
  STA $13
  PLA
  STA $12
  PLA
  STA $10
  PLA
  TAY
  RTS
.ENDPROC ; SpiByte

; SpiByteFast exchanges register X over SPI.
; Fixed pin assignments: clock: 0, mosi: 6, miso: 7
; Clock must be initialized low.
.PROC SpiByteFastPortB
  mask_clock = %00000001
  mask_mosi  = %01000000
  mask_miso  = %10000000
  port = $C000

  LDY #8 ; loop for 8 bits
eachBit:
  ; write MOSI
  TXA
  AND #(1 << 7) ; MSB
  BEQ writeZero
writeOne:
  LDA port
  ORA #mask_mosi
  JMP write
writeZero:
  LDA port
  AND #~mask_mosi
write:
  STA port ; write

  TXA
  ASL ; push next most significant bit to front.
      ; A is now authoritative for the working value.

  ; clock high
  INC port

  ; read MISO
  BIT port     ; assign bit 7 to negative flag
  BMI readOne  ; branch if bit 7 was set
readZero:
  AND #~1
  JMP read
readOne:
  ORA #1
  JMP read
read:
  TAX ; new bit set into x[0], which will be shifted left until byte read.

  ; clock low
  DEC port

  DEY
  BNE eachBit

  RTS
.ENDPROC
