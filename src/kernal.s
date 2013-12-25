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
TXS          ; set stack pointer to $ff (zeropage)
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

; Some noise to indicate Main
; (and a large address range to estimate a jump into)
NOP
NOP
NOP
NOP

;;; VIA at 0xC000
; Configure PORT A write handshake
LDX #$0A   ; 00001010 (pulse output)
STX $C00C  ; PCR register
; Write to data direction registers:
LDX #$FF   ; direction: output
STX $C003  ; DDRA

; Write to output registers:
LDX #$00
NextChar:
  LDY Message,X
  STY $C001  ; ORA
  INX
  CPX #14  ; Length of message
  BEQ Halt
  JMP NextChar



JMP Halt


JMP Main


Halt:
;--------
JMP Halt

Message:
.asciiz "Hello pda6502"
