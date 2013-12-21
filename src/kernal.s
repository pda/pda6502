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
  CMP #$10
  BNE Loop ; exit loop when Y == 16 ($10)

LDX #$4C  ; JMP
STX $10
LDX #$10  ; low address of main-ish (NOPS)
STX $11
LDX #$E0  ; high address of main-ish (NOPS)
STX $12

JMP $00 ; jump to NOP sled, it should jump us back to main

JMP Main
