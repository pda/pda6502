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
; Addresses are relative to the entire device, not the partition.
FatStartAddress: .dword 0 ; first partition according to MBR LBA field.
FatFatOffset: .dword 0    ; location of first FAT
FatFatSize: .dword 0      ; size in bytes of each FAT
FatFatTotalSize: .dword 0 ; total size of FATs (count x size)
FatDataAddress: .dword 0  ; cluster #0 address (but first valid cluster is #2)
FatClusterSize: .word 0   ; size of each cluster in bytes
FatRootAddress: .dword 0  ; location of first cluster of root directory


.segment "kernal"

; Read and calculate FAT parameters.
.PROC FatInit
  JSR readMbrParameters
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

.PROC readMbrParameters
  dir_entry = sd_buffer + $01BE
  first_sector = dir_entry + 8
  ; Load LBA start address; first sector.
  ; Store as start byte address; assume 512-byte sectors.
  JSR readFirstBlock
  LDA #0
  STA FatStartAddress + 0
  LDA first_sector + 0
  ASL
  STA FatStartAddress + 1
  LDA first_sector + 1
  ROL
  STA FatStartAddress + 2
  LDA first_sector + 2
  ROL
  STA FatStartAddress + 3
  RTS
.ENDPROC

.PROC readFatParameters
  ; Read first block of FAT partition.
  LDA FatStartAddress + 0
  JSR StackPush
  LDA FatStartAddress + 1
  JSR StackPush
  LDA FatStartAddress + 2
  JSR StackPush
  LDA FatStartAddress + 3
  JSR StackPush
  JSR SdCardRead

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
  ; calculations are order-sensitive; later ones depend on earlier ones.
  JSR calculateFatOffset
  JSR calculateFatSize
  JSR calculateFatTotalSize
  JSR calculateClusterSize
  JSR calculateDataAddress
  JSR calculateRootAddress
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

; Calculate the total size of the FATs.
; FatFatCount * FatFatSize
.PROC calculateFatTotalSize
  LDX FatFatCount
loop:
  BEQ loopDone
  LDA FatFatSize + 0
  ASL
  STA FatFatTotalSize + 0
  LDA FatFatSize + 1
  ROL
  STA FatFatTotalSize + 1
  LDA FatFatSize + 2
  ROL
  STA FatFatTotalSize + 2
  LDA FatFatSize + 3
  ROL
  STA FatFatTotalSize + 3
  DEX
  JMP loop
loopDone:
  RTS
.ENDPROC

; Calculate the base address for cluster-indexed data.
; The first valid cluster is #2, being (FatDataAddress + 2*FatClusterSize).
; So, this base address is actually 2*FatClusterSize before the data region.
; (uint32)FatStartAddress
; + (uint32)FatFatOffset
; + (uint32)FatFatTotalSize
; - 2*(uint16)FatClusterSize
.PROC calculateDataAddress
  CLC
  LDA FatFatOffset + 0
  ADC FatFatTotalSize + 0
  STA FatDataAddress + 0
  LDA FatFatOffset + 1
  ADC FatFatTotalSize + 1
  STA FatDataAddress + 1
  LDA FatFatOffset + 2
  ADC FatFatTotalSize + 2
  STA FatDataAddress + 2
  LDA FatFatOffset + 3
  ADC FatFatTotalSize + 3
  STA FatDataAddress + 3

  ; Add to FatStartAddress (start of filesystem / partition)
  LDA FatDataAddress + 0
  ADC FatStartAddress + 0
  STA FatDataAddress + 0
  LDA FatDataAddress + 1
  ADC FatStartAddress + 1
  STA FatDataAddress + 1
  LDA FatDataAddress + 2
  ADC FatStartAddress + 2
  STA FatDataAddress + 2
  LDA FatDataAddress + 3
  ADC FatStartAddress + 3
  STA FatDataAddress + 3

  ; subtract 16-bit 2*FatClusterSize from 32-bit FatDataAddress
  ; Compensates for the two special/reserved clusters which have no data.
  LDX #2
subtractClusterSizeLoop:
  BEQ subtractClusterSizeDone
  SEC
  LDA FatDataAddress + 0
  SBC FatClusterSize + 0
  STA FatDataAddress + 0
  LDA FatDataAddress + 1
  SBC FatClusterSize + 1
  STA FatDataAddress + 1
  LDA FatDataAddress + 2
  SBC #0
  STA FatDataAddress + 2
  DEX
  JMP subtractClusterSizeLoop
subtractClusterSizeDone:

  RTS
.ENDPROC

; Calculate the size of each cluster.
; (uint8)FatSectorsPerCluster * (uint16)FatSectorSize
; Assume FatSectorSize == 512
; FatSectorsPerCluster * 512
; FatSectorsPerCluster << 9
.PROC calculateClusterSize
  LDA #0
  STA FatClusterSize + 0       ; product[0] <- 0
  LDA FatSectorsPerCluster + 0 ; input LSB
  ASL                          ; shift left one more bit to make <<9
  STA FatClusterSize + 1       ; product[1] <- input[0]<<1
  RTS
.ENDPROC

; Calculate location first cluster of root directory.
; (uint32)FatDataAddress + (uint32)FatRootCluster * (uint16)FatClusterSize
; Assume FatRootCluster == 2 for now.
; (uint32)FatDataAddress + (uint32)FatClusterSize * 2
; (uint32)FatDataAddress + (uint32)FatClusterSize<<1
.PROC calculateRootAddress
  ; Load FatClusterSize<<1 into FatRootAddress
  LDA FatClusterSize + 0
  ASL
  STA FatRootAddress + 0
  LDA FatClusterSize + 1
  ROL
  STA FatRootAddress + 1
  LDA FatClusterSize + 2
  ROL
  STA FatRootAddress + 2
  LDA FatClusterSize + 3
  ROL
  STA FatRootAddress + 3
  ; Add FatDataAddress to FatRootAddress
  CLC
  LDA FatRootAddress + 0
  ADC FatDataAddress + 0
  STA FatRootAddress + 0
  LDA FatRootAddress + 1
  ADC FatDataAddress + 1
  STA FatRootAddress + 1
  LDA FatRootAddress + 2
  ADC FatDataAddress + 2
  STA FatRootAddress + 2
  LDA FatRootAddress + 3
  ADC FatDataAddress + 3
  STA FatRootAddress + 3
  RTS
.ENDPROC
