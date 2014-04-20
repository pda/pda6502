; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.import Main

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
TXS          ; set stack pointer to $ff ($01FF)
CLI          ; resume interrupts
CLD          ; don't be in crazy decimal mode.
JMP Main

Interrupt:
;--------
RTI

NonMaskableInterrupt:
;--------
RTI
