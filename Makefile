SOURCES=$(wildcard src/*.s)
OBJECTS=$(SOURCES:.s=.o)

CA      = ca65
CAFLAGS = --debug-info
LD      = ld65
LDFLAGS = --mapfile build/memory.map --config memory.conf --dbgfile build/debug

.DUMMY: all

all: $(OBJECTS)
	$(LD) $(LDFLAGS) $^

src/%.o: src/%.s
	$(CA) $(CAFLAGS) -o $@ $(@:.o=.s)

clean:
	$(RM) $(OBJECTS) build/*


.DUMMY: burn burnchar burnkernal
MEEPROMER = ./tools/meepromer.py -c /dev/cu.usbmodem14*

burn: burnchar burnkernal
burnchar: writechar verifychar
burnkernal: writekernal verifykernal

writechar:
	$(MEEPROMER) -w -a 0x0000 -b 4 -f build/char.rom

verifychar:
	$(MEEPROMER) -v -a 0x0000 -b 4 -f build/char.rom

writekernal:
	$(MEEPROMER) -w -a 0x1000 -b 4 -f build/kernal.rom

verifykernal:
	$(MEEPROMER) -v -a 0x1000 -b 4 -f build/kernal.rom

verifyrom: build/combined.rom
	$(MEEPROMER) -v -f build/combined.rom

build/combined.rom: build/kernal.rom build/char.rom
	cat build/char.rom build/kernal.rom > build/combined.rom
