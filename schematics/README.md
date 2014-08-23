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

* power headers.
* memory mapping logic headers.
* CPU misc signal headers.

Diode:
STPS2L40AF 2A 40V SMAflat, 0.39V drop
http://www.mouser.com/ProductDetail/STMicroelectronics/STPS2L40AF/?qs=xEJ61ozf1a1/e1UEQFOFcw==
B340A 3A 40V SMA, 0.5V drop
http://www.mouser.com/ProductDetail/Diodes-Incorporated/B340A-13-F/?qs=sGAEpiMZZMtQ8nqTKtFS%2fLDoMakfJd%2f0jr6cVnY7CxE%3d
http://www.mouser.com/ProductDetail/Vishay-Semiconductors/B340A-E3-61T/?qs=sGAEpiMZZMtQ8nqTKtFS%2fJkHNs4hgXaDNz7G8vLeA%2fM%3d

Micro B USB socket:
Dangerous Prototypes Eagle library.
Device: CONN-USB-MICRO-B
USB micro-b connector SMT 0.65 mm pitch, 1.45mm from center to PCB edge, Based on TE part number 1981568-1
http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/1981568-1/?qs=zxTme0yW/baAfvOKTKC5hw==


Memory mapping logic
--------------------

IN:  CPU A12
IN:  CPU A13
IN:  CPU A14
IN:  CPU A15
IN:  CPU PHI2
IN:  CPU PHI1O
IN:  CPU RWB
OUT: RAM OE+CE
OUT: ROM OE+CE
OUT: VIA CS2B

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
