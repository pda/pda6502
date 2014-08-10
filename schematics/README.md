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