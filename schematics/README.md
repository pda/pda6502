pda6502 schematics
==================

Schematics for pda6502 hardware builds.

Disclaimer: I have no idea what I'm doing.

First iteration is aiming towards a core board for the 6502, 6522, ROM, RAM and
oscillator.  It would connect the power, data bus, address bus, reset lines and
clock lines.  All other functionality (including memory-mapping logic) would be
external via headers.

A 2x10 header exposes the 6522 VIA ports A and B and their control lines.

Notes / TODO
------------

* Two spare pins on 40-pin expansion header.
    * routing them is difficult.
* Jumper on TFT+SD BL to 6522 CB2 to disconnect if undesired?
* replace large SMD capacitors with TH?
* verify USB port alignment with edge of board.
* tent vias - https://www.sparkfun.com/tutorials/115
* Check drill size for ROM ZIF socket; giant pins.
* Label top and bottom of all headers.
* modify breadboard prototype to match schematics.


Micro B USB socket:
Dangerous Prototypes Eagle library.
Device: CONN-USB-MICRO-B
USB micro-b connector SMT 0.65 mm pitch, 1.45mm from center to PCB edge, Based on TE part number 1981568-1
http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/1981568-1/?qs=zxTme0yW/baAfvOKTKC5hw==


Memory mapping logic
--------------------

* IN:  CPU A12
* IN:  CPU A13
* IN:  CPU A14
* IN:  CPU A15
* IN:  CPU PHI2
* IN:  CPU PHI1O
* IN:  CPU RWB
* OUT: RAM OE+CE
* OUT: ROM OE+CE
* OUT: VIA CS2B


Logic chips:

* 74HC00 (quad NAND) acting as inverter, NAND gate, and AND gate.
* 74HC138 (3-bit decoder) to split the upper-half of address space.

Propagation times:

* 74HC00 gates: typical 8 ns, max 23 ns.
* 74HC138: typical 15 ns, max 38 ns.

* RAM: invert (NAND) + NAND = typical 16 ns, max 46 ns.
* VIA: 74HC138 = typical 15 ns, max 38 ns.
* ROM: 74HC138 + (NAND + NAND) = typical 31 ns, max 84 ns.

* RAM speed: 12 ns
* ROM speed: 250 ns or 120 ns? 150 ns for Atmel AT28C256-15




Power characteristics
---------------------

Designing for maximum of 1A current should be plenty:

[vreg]: http://www.mouser.com/Search/ProductDetail.aspx?R=MC7805CDTRKGvirtualkey58410000virtualkey863-MC7805CDTRKG

```
65C02: 12 mA @ 8 MHz; 1.5 mA per MHz supply current (loaded)
65C22:  4 mA @ 8 MHz; 0.5 mA per MHz supply current (loaded)
28C64: 30 mA max.
SRAM: 200 mA max; 80 mA typical
      ==========
      246 mA max (chips)
      ==========
TFT:  100 mA
uSD:  100 mA (max during writes)
xprot: 60 mA
oled:  20 mA
      ==========
      526 mA
      ==========
```
