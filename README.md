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

Address bus 4 KB chunks:

```
     High   Dec  Dec
Seg  Bits    In  Out  Base    Function
------------------------------------------------
  0  0000             0x0000  RAM
  1  0001             0x1000  RAM
  2  0010             0x2000  RAM
  3  0011             0x3000  RAM
  4  0100             0x4000  RAM
  5  0101             0x5000  RAM
  6  0110             0x6000  RAM
  7  0111             0x7000  RAM
  8  1000   000    0  0x8000
  9  1001   001    1  0x9000
  A  1010   010    2  0xA000
  B  1011   011    3  0xB000
  C  1100   100    4  0xC000  IO (VIA)
  D  1101   101    5  0xD000
  E  1110   110    6  0xE000  ROM (KERNAL)
  F  1111   111    7  0xF000  ROM (KERNAL)
```

* 74HC138 (3-to-8 decoder)
    * G1 (active-high enable) driven by A15 (only active 0x8000 and above)
    * G2 (active-low enable) permanently LOW/enabled.
    * Inputs A, B, C driven by A12, A13, A14.
    * Output Y4 enables VIA.
    * Output Y6 & Y7 drive KERNAL ROM via AND gate.
* 74HC08 (Quad 2-input AND gates)
    * Input A1, B1 from 74HC138 Y6, Y7, output Y1 to KERNAL ROM CE/OE.
    * Input A2, B2 from phase2, A15, output Y2 to RAM CS/OE.
    * Three spare AND gates.
* 74HC00 (Quad 2-input NAND gates)
    * Input A1, B1 from A15 (as inverter), output Y1 to A2.
    * Input A2, B2 from Y1, phase2 clock, output Y2 to RAM CS/OE.
* VIA 6522
    * CS1 permanently HIGH/active.
    * CS2B to 74HC138 Y4 (LOW/active for `0b1110____`).
    * Data 0..7 to data bus D0..7.
    * Address 0..3 to address bus A0..3.
    * RWB to 6502 RWB.
    * PHI2 to system oscillator, same as 6502.
    * RESB to reset button, same as 6502.
* ROM AT28C64
    * CE and OE both active-low, tied together.
    * CE/OE to 74HC08 Y1, (LOW/active for `0b111_____`)
    * WE permanently HIGH/inactive.
    * I/O 0..7 to data bus D0..7.
    * Address 0..12 to address bus A0..12.
* RAM (32Kx8 CMOS SRAM; UM61256AK-12)
    * CE and OE both active-low, tied together.
    * CE/OE driven by A15+phase2 via 74HC00 (LOW/active for `0b0_______`)
    * WE (active low) to 6502 RWB.
    * Address 0..14 to address bus A0..14.


*Initial, minimal implementation*

6502, 74HC138, 8KB ROM, VIA 6522. No RAM.

8kb segment memory map - upper 3 bits to 74HC138.

```
     High   Dec  Dec
Seg  Bits    In  Out  Base    Function
--------------------------------------------
  0   000   000    0  0x0000
  1   001   001    1  0x2000
  2   010   010    2  0x4000
  3   011   011    3  0x6000
  4   100   100    4  0x8000
  5   101   101    5  0xA000
  6   110   110    6  0xC000  IO (VIA)
  7   111   111    7  0xE000  ROM (KERNAL)
```

* VIA 6522
    * To access registers; CS1: HIGH, CS2B: LOW.
    * CS1 permanently HIGH/active.
    * CS2B to 74HC138 Y6 (LOW/active for `0b110_____`).
* ROM AT28C64
    * CE and OE both active-low, tied together.
    * CE/OE to 74HC138 Y7 (LOW/active for `0b111_____`)
    * WE permanently HIGH/inactive.


Zero Page
---------

The zero page (`0x0000..0x00FF`) is frequently used as "external registers".

Note that Some 6502 derivatives dedicate the first few bytes to hardware ports and
control registers, best avoid those? e.g. 6510 in C64 uses at least two.

* `0x0010..0x0017` - local temporary data; subroutines can overwrite.
