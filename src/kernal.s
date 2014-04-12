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


HelloMessageLoop:

  ; Hello
  LDY #$00
HelloNextChar:
  LDA Message,Y
  STA $C001  ; VIA ORA
  INY
  CPY #14  ; length of message with \n, but not \0
  BNE HelloNextChar ; Next char if more..

  JMP HelloMessageLoop ; Otherwise, back to the start.


Halt:
;--------
JMP Halt

; Data
;-----

Message: .byte "Hello pda6502", $0A, $00
