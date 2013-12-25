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
* 6522 VIA (I/O) has 4-bit RS (register select), needs 16 bytes mapped.
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
* 0x8000..0xBFFF: (reserved)
* 0xC000..0xCFFF: 4K I/O (initially only 16 bytes used by 6522 VIA)
* 0xD000..0xDFFF: (reserved)
* 0xE000..0xFFFF: 8K ROM ("kernal" [sic])

Address table for upper 3 bits of address bus:

NOTE: A15 can directly control RAM's CE/OE.
      This means a 74HC138 decoder can run on A12..14
      (With A15 as the '138 active-high enable input)

```
Address bus 4 KB chunks:
0000: RAM (0x0000)
0001: RAM
0010: RAM
0011: RAM
0100: RAM
0101: RAM
0110: RAM
0111: RAM
1000:
1001:
1010:
1011:
1100: IO (0xC000)
1101:
1110: KERNAL (0xE000)
1111: KERNAL
```

