; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

; Where bignum is anything more than 8-bit.

.export Uint32Multiply

.export Uint32Multiplicand
.export Uint32Multiplier
.export Uint32Product

.segment "kernal_bss"

Uint32Multiplicand: .dword 0
Uint32Multiplier: .dword 0
Uint32Product: .dword 0
Uint32ProductHighDword: .dword 0

.segment "kernal"

; Multiple uint32*uint32 into uint64 result.
; Adapted from:
; http://6502.org/source/integers/32muldiv.htm
.PROC Uint32Multiply
           LDA #0
           STA Uint32Product+4      ; Clear upper half of
           STA Uint32Product+5      ; product
           STA Uint32Product+6
           STA Uint32Product+7
           LDX #32                  ; Set binary count to 32
shift_r:   LSR Uint32Multiplier+3   ; Shift multiplyer right
           ROR Uint32Multiplier+2
           ROR Uint32Multiplier+1
           ROR Uint32Multiplier
           BCC rotate_r             ; Go rotate right if c = 0
           LDA Uint32Product+4      ; Get upper half of product
           CLC                      ; and add multiplicand to
           ADC Uint32Multiplicand   ; it
           STA Uint32Product+4
           LDA Uint32Product+5
           ADC Uint32Multiplicand+1
           STA Uint32Product+5
           LDA Uint32Product+6
           ADC Uint32Multiplicand+2
           STA Uint32Product+6
           LDA Uint32Product+7
           ADC Uint32Multiplicand+3
rotate_r:  ROR a                    ; Rotate partial product
           STA Uint32Product+7      ; right
           ROR Uint32Product+6
           ROR Uint32Product+5
           ROR Uint32Product+4
           ROR Uint32Product+3
           ROR Uint32Product+2
           ROR Uint32Product+1
           ROR Uint32Product
           DEX                      ; Decrement bit count and
           BNE shift_r              ;  loop until 32 bits are
           CLC                      ;  done
           RTS
.ENDPROC
