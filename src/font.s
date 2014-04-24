; asmsyntax=asmM6502 (http://cc65.github.io/cc65/)

.export FontData

.segment "kernal"

; Generated with:
; head -c512 c64.rb/rom/character.rom | \
;   hexdump -e '".byte " 16/1 "$%02X, " "\n"'
; .. and then strip trailing commas.


; Each char is eight consecutive bytes:
;
; 0:  0x3C:  ..####..
; 1:  0x66:  .##..##.
; 2:  0x6E:  .##.###.
; 3:  0x6E:  .##.###.
; 4:  0x60:  .##.....
; 5:  0x62:  .##...#.
; 6:  0x3C:  ..####..
; 7:  0x00:  ........

FontData:
.byte $3C, $66, $6E, $6E, $60, $62, $3C, $00, $18, $3C, $66, $7E, $66, $66, $66, $00
.byte $7C, $66, $66, $7C, $66, $66, $7C, $00, $3C, $66, $60, $60, $60, $66, $3C, $00
.byte $78, $6C, $66, $66, $66, $6C, $78, $00, $7E, $60, $60, $78, $60, $60, $7E, $00
.byte $7E, $60, $60, $78, $60, $60, $60, $00, $3C, $66, $60, $6E, $66, $66, $3C, $00
.byte $66, $66, $66, $7E, $66, $66, $66, $00, $3C, $18, $18, $18, $18, $18, $3C, $00
.byte $1E, $0C, $0C, $0C, $0C, $6C, $38, $00, $66, $6C, $78, $70, $78, $6C, $66, $00
.byte $60, $60, $60, $60, $60, $60, $7E, $00, $63, $77, $7F, $6B, $63, $63, $63, $00
.byte $66, $76, $7E, $7E, $6E, $66, $66, $00, $3C, $66, $66, $66, $66, $66, $3C, $00
.byte $7C, $66, $66, $7C, $60, $60, $60, $00, $3C, $66, $66, $66, $66, $3C, $0E, $00
.byte $7C, $66, $66, $7C, $78, $6C, $66, $00, $3C, $66, $60, $3C, $06, $66, $3C, $00
.byte $7E, $18, $18, $18, $18, $18, $18, $00, $66, $66, $66, $66, $66, $66, $3C, $00
.byte $66, $66, $66, $66, $66, $3C, $18, $00, $63, $63, $63, $6B, $7F, $77, $63, $00
.byte $66, $66, $3C, $18, $3C, $66, $66, $00, $66, $66, $66, $3C, $18, $18, $18, $00
.byte $7E, $06, $0C, $18, $30, $60, $7E, $00, $3C, $30, $30, $30, $30, $30, $3C, $00
.byte $0C, $12, $30, $7C, $30, $62, $FC, $00, $3C, $0C, $0C, $0C, $0C, $0C, $3C, $00
.byte $00, $18, $3C, $7E, $18, $18, $18, $18, $00, $10, $30, $7F, $7F, $30, $10, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $18, $00, $00, $18, $00
.byte $66, $66, $66, $00, $00, $00, $00, $00, $66, $66, $FF, $66, $FF, $66, $66, $00
.byte $18, $3E, $60, $3C, $06, $7C, $18, $00, $62, $66, $0C, $18, $30, $66, $46, $00
.byte $3C, $66, $3C, $38, $67, $66, $3F, $00, $06, $0C, $18, $00, $00, $00, $00, $00
.byte $0C, $18, $30, $30, $30, $18, $0C, $00, $30, $18, $0C, $0C, $0C, $18, $30, $00
.byte $00, $66, $3C, $FF, $3C, $66, $00, $00, $00, $18, $18, $7E, $18, $18, $00, $00
.byte $00, $00, $00, $00, $00, $18, $18, $30, $00, $00, $00, $7E, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $18, $18, $00, $00, $03, $06, $0C, $18, $30, $60, $00
.byte $3C, $66, $6E, $76, $66, $66, $3C, $00, $18, $18, $38, $18, $18, $18, $7E, $00
.byte $3C, $66, $06, $0C, $30, $60, $7E, $00, $3C, $66, $06, $1C, $06, $66, $3C, $00
.byte $06, $0E, $1E, $66, $7F, $06, $06, $00, $7E, $60, $7C, $06, $06, $66, $3C, $00
.byte $3C, $66, $60, $7C, $66, $66, $3C, $00, $7E, $66, $0C, $18, $18, $18, $18, $00
.byte $3C, $66, $66, $3C, $66, $66, $3C, $00, $3C, $66, $66, $3E, $06, $66, $3C, $00
.byte $00, $00, $18, $00, $00, $18, $00, $00, $00, $00, $18, $00, $00, $18, $18, $30
.byte $0E, $18, $30, $60, $30, $18, $0E, $00, $00, $00, $7E, $00, $7E, $00, $00, $00
.byte $70, $18, $0C, $06, $0C, $18, $70, $00, $3C, $66, $06, $0C, $18, $00, $18, $00