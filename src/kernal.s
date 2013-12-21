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

;;; VIA at 0xD000
; Write to data direction registers:
LDX #$FF
STX $D003  ; DDRA
LDX #$AA
STX $D002  ; DDRB
; Write to output registers:
LDX #$DE
STX $D001  ; ORA
LDX #$AD
STX $D000  ; ORB


; Some noise to indicate Main
; (and a large address range to estimate a jump into)
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP

LDY #$00 ; loop counter
Loop:
  LDX #$EA ; NOP sled! but to where..?
  STX $00,Y
  INY
  TYA
  CMP #$20
  BNE Loop ; exit loop when Y == 32 ($10)

LDX #$4C  ; JMP
STX $20
LDX #$10  ; low address of main-ish (NOPS)
STX $21
LDX #$E0  ; high address of main-ish (NOPS)
STX $22

JMP $00 ; jump to NOP sled, it should jump us back to main

JMP Main
