pda6502
=======

Code and notes for a 6502-based breadboard computer.

NB: I have no idea what I'm doing.


Address layout
--------------

Considerations:

* 6502 has 16-bit address bus; can address 64K memory.
* Zero-page (0x0000..0x00FF) must be RAM, used as external registers.
* Stack (0x0100..0x00FF) must be RAM.
* PC (program counter) is initialized from 0xFFFC, so must be ROM.
* 6522 VIA (I/O) wants 16 bytes mapped.
* AT28C64 EEPROMs are 8kb. I have some.
* Fancy bank-switching (e.g. ROMs overlaying RAM, C64-style) would be cool.
