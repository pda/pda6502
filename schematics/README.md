pda6502 schematics
==================

Schematics for pda6502 hardware builds.

Disclaimer: I have no idea what I'm doing.

First iteration is aiming towards a core board for the 6502, 6522, ROM, RAM and
oscillator.  It would connect the power, data bus, address bus, reset lines and
clock lines.  All other functionality (including memory-mapping logic) would be
external via headers.

A 2x10 header exposes the 6522 VIA ports A and B and their control lines.

A 2x20 header exposes the address and data bus in a way compatible with
40-pin ribbon PATA cables. As the ground connections match, an 80-conductor
cable can be used to interleave ground wires between each signal wire.

Notes / TODO
------------

* button for reset circuit.
* VIA CS1 HIGH.
* power connector (9V barrel?)
* voltage regulator.
* power capacitor.
* power headers
* glue logic headers
* CPU headers

Memory mapping logic
--------------------

Six inputs:
Clock: PH1O, PH2O
Address: A12, A13, A14, A15

Three outputs:
RAM: OE+CE
ROM: OE+CE
VIA: CS2B
