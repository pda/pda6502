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

.segment "kernal"

; Read and calculate FAT parameters.
.PROC FatInit

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
