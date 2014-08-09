pda6502 schematics
==================

Schematics for pda6502 hardware builds.

Disclaimer: I have no idea what I'm doing.

First iteration is aiming towards a core board for the 6502, 6522, ROM, RAM and
oscillator.  It would connect the power, data bus, address bus, reset lines and
clock lines.  All other functionality (including memory-mapping logic) would be
external via headers.

Given board space, the address and data lines would be exposed, perhaps via a
24-pin ribbon cable connector.
