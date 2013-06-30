
PREFIX ?= /home/users/stephen/bins/atheme

SRVNAME = groupserv

ATHEME_CFLAGS = -I$(ATHEME)/include -I$(ATHEME)/libmowgli/src/libmowgli -DDATADIR=\"$(PREFIX)/etc\"

SOURCES = \
	gmsserv.pl

MODULES = $(patsubst %.c,%.so,$(SOURCES))

default: $(MODULES)

clean:
	rm -f $(MODULES)

.PHONY: install

install: $(MODULES)
	mkdir -p $(PREFIX)/modules/scripting/lib/gms/
	install -t $(PREFIX)/modules/scripting/lib/gms/ $(MODULES)
