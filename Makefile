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