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
TXS          ; set stack pointer to $ff (0x01FF)
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

  ;;; VIA at 0xC000
  ; Configure PORT A write handshake
  LDX #$0A   ; 00001010 (CA2 pulse output)
  STX $C00C  ; PCR register
  ; Write to data direction registers:
  LDX #$FF   ; direction: output
  STX $C003  ; DDRA

;;; Copy message to RAM at 0x2000.
  LDX #$00
StoreHelloNextChar:
  LDA Message,X
  STA $2000,X
  INX
  CMP #0  ; string null terminator
  BNE StoreHelloNextChar ; Next char if more..

  ; s/pda/RAM/
  LDA #$52
  STA $2006
  LDA #$41
  STA $2007
  LDA #$4D
  STA $2008

HelloMessageLoop:

  ; Hello ROM
  LDY #$FF
HelloRomNextChar:
  INY
  LDA Message,Y
  CMP #0
  BEQ HelloRomDone
  STA $C001  ; VIA ORA
  JMP HelloRomNextChar
HelloRomDone:

  ; Hello RAM
  LDY #$FF
HelloRamNextChar:
  INY
  LDA $2000,Y
  CMP #0
  BEQ HelloRamDone
  STA $C001  ; VIA ORA
  JMP HelloRamNextChar
HelloRamDone:

  JMP HelloMessageLoop ; Otherwise, back to the start.


Halt:
;--------
JMP Halt

; Data
;-----

Message: .byte "Hello pda6502", $0A, $00
