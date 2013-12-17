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
* Nice to have:
  * Fancy bank-switching (e.g. ROMs overlaying RAM, C64-style).
  * Different mapping for read vs. write, e.g. read ROM, write RAM.

Address bus pin numbers, and the address blocks they can switch between:

* Pin 15 controls two 32K blocks.
* Pins 15, 14 control four 16K blocks.
* Pins 15, 14, 13 control eight 8K blocks.
* Pins 15, 14, 13, 12 control sixteen 4K blocks.
* ... etc

74HC521/74HC688 can route a specific page (256 bytes, upper 8 bits of address)
to a destination. See http://wilsonminesco.com/6502primer/addr_decoding.html

So using the highest three pins of the address bus, the memory space
can be divided down to 8K blocks.

A simple RAM+ROM+IO scheme:
Allows for future extensions e.g. upper 32K RAM, with ROMs and I/O overlaid.

* 0x0000..0x7FFF: 32K RAM, uninterrupted. Contains zero-page and stack.
* 0x8000..0xCFFF: Unused (reserved)
* 0xD000..0xDFFF: 4K I/O (initially only 16 bytes used by 6522 VIA)
* 0xE000..0xFFFF: 8K ROM ("kernal" [sic])

Address table for upper 3 bits of address bus:

```
000: RAM
001: RAM
010: RAM
011: RAM
100: (invalid)
101: (invalid)
110: IO
111: KERNAL
```
