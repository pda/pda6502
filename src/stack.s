; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.segment "kernal"

;----------------------------------------
; User stack, as distinct from the 6502 hardware stack.
; Starts at stack_base + $FF and grows downwards.
; Used for arbitrary data without interfering with return address etc.

.export StackInit
.export StackPush
.export StackPop

stack_base = $0200
stack_ptr = $FF ; zero-page address of stack pointer

; Initialize the user stack.
.PROC StackInit
  LDA #$FF
  STA stack_ptr
  RTS
.ENDPROC

; Push A onto the stack.
.PROC StackPush
  PHA  ; stash A
  TXA  ; preserve X
  PHA
  TSX
  LDA $0102,X ; fetch A from beneath X
  LDX stack_ptr
  STA stack_base,X  ; stack <- A
  DEC stack_ptr     ; stack grows downwards, point at next free byte.
  PLA  ; restore X
  TAX
  PLA  ; balance stack; also happens to restore A.
  RTS
.ENDPROC

; Pop from stack into A.
.PROC StackPop
  PHA ; placeholder for A
  TXA ; preserve X
  PHA
  INC stack_ptr     ; stack shrinks upwards
  LDX stack_ptr
  LDA stack_base,X  ; A <- tip of stack
  TSX
  STA $0102,X ; placeholder <- A
  PLA ; restore X
  TAX
  PLA ; restore A from placeholder
  RTS
.ENDPROC
