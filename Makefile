SOURCES = src/kernal.s
OBJECTS=$(SOURCES:.s=.o)

CA      = ca65
LD      = cl65
LDFLAGS = --mapfile build/memory.map --config memory.conf

all: $(OBJECTS)
	$(LD) $(LDFLAGS) $^

src/%.o: src/%.s
	$(CA) -o $@ $(@:.o=.s)

clean:
	$(RM) $(OBJECTS) build/*

burn: build/kernal.rom
	./tools/meepromer.py -c /dev/cu.usbmodem14* -w -f build/kernal.rom
	./tools/meepromer.py -c /dev/cu.usbmodem14* -v -f build/kernal.rom
