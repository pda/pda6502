; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export FatInit

.import SdCardRead
.import StackPush

sd_buffer = $6000

.segment "kernal_bss"

; Stored parameters
FatSectorSize: .word 0
FatSectorsPerCluster: .byte 0
FatReservedSectors: .word 0
FatFatCount: .byte 0
FatSectorsPerFat: .dword 0
FatRootCluster: .dword 0

; Calculated parameters
FatFatOffset: .dword 0
FatFatSize: .dword 0


.segment "kernal"

; Read and calculate FAT parameters.
.PROC FatInit
  JSR readFatParameters
  JSR calculateFatParameters
  RTS
.ENDPROC

.PROC readFirstBlock
  ; push (uint32)0 onto user-stack.
  LDA #$00 ; LSB
  JSR StackPush
  LDA #$00
  JSR StackPush
  LDA #$00
  JSR StackPush
  LDA #$00 ; MSB
  JSR StackPush
  JSR SdCardRead ; 512 byte block from address on user-stack into $6000.
  RTS
.ENDPROC

.PROC readSecondBlock
  ; push (uint32)$200 onto user-stack.
  LDA #$00 ; LSB
  JSR StackPush
  LDA #$02
  JSR StackPush
  LDA #$00
  JSR StackPush
  LDA #$00 ; MSB
  JSR StackPush
  JSR SdCardRead ; 512 byte block from address on user-stack into $6000.
  RTS
.ENDPROC

.PROC readFatParameters
  JSR readFirstBlock

  ; FatSectorSize
  LDA sd_buffer + $000B
  STA FatSectorSize
  LDA sd_buffer + $000B + 1
  STA FatSectorSize + 1

  ; FatSectorsPerCluster
  LDA sd_buffer + $000D
  STA FatSectorsPerCluster

  ; FatReservedSectors
  LDA sd_buffer + $000E
  STA FatReservedSectors
  LDA sd_buffer + $000E + 1
  STA FatReservedSectors + 1

  ; FatFatCount
  LDA sd_buffer + $0010
  STA FatFatCount

  ; FatSectorsPerFat (FAT32 version)
  LDA sd_buffer + $0024
  STA FatSectorsPerFat
  LDA sd_buffer + $0024 + 1
  STA FatSectorsPerFat + 1
  LDA sd_buffer + $0024 + 2
  STA FatSectorsPerFat + 2
  LDA sd_buffer + $0024 + 3
  STA FatSectorsPerFat + 3

  ; FatRootCluster (FAT32)
  LDA sd_buffer + $002C
  STA FatRootCluster
  LDA sd_buffer + $002C + 1
  STA FatRootCluster + 1
  LDA sd_buffer + $002C + 2
  STA FatRootCluster + 2
  LDA sd_buffer + $002C + 3
  STA FatRootCluster + 3
  RTS
.ENDPROC

.PROC calculateFatParameters
  JSR calculateFatOffset
  JSR calculateFatSize
  RTS
.ENDPROC

; Calculate address of first FAT.
; Assume sector size is 512.
.PROC calculateFatOffset
  ; FatSectorSize [assume 512] * FatReservedSectors
  ; FatReservedSectors << 9
  ; First left-shift by entire byte.
  LDA #0
  STA FatFatOffset + 0       ; product[0] <- 0
  LDA FatReservedSectors + 0 ; input LSB
  ASL                        ; shift left one more bit to make <<9
  STA FatFatOffset + 1       ; product[1] <- input[0]<<1
  LDA FatReservedSectors + 1
  ROL                        ; shift left with carry from ASL
  STA FatFatOffset + 2       ; product[2] <- input[1]<<1
  LDA #0                     ; if carry clear
  BCC storeHighByte
  LDA #1                     ; else if carry set
storeHighByte:
  STA FatFatOffset + 3       ; product[3] <- carry ? 1 : 0
  RTS
.ENDPROC

; Calculate size in bytes of each FAT.
; Assume sector size is 512.
.PROC calculateFatSize
  LDA #0
  STA FatFatSize + 0       ; product[0] <- 0
  LDA FatSectorsPerFat + 0   ; input LSB
  ASL                        ; shift left one more bit to make <<9
  STA FatFatSize + 1       ; product[1] <- input[0]<<1
  LDA FatSectorsPerFat + 1
  ROL                        ; shift left with carry from ASL
  STA FatFatSize + 2       ; product[2] <- input[1]<<1
  LDA FatSectorsPerFat + 2
  ROL                        ; shift left with carry from ASL
  STA FatFatSize + 3       ; product[3] <- input[2]<<1
  RTS
.ENDPROC
