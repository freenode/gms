
PREFIX ?= /home/gms/freenode/atheme/
ATHEME ?= /home/gms/atheme

SUBDIR = freenode

ATHEME_CFLAGS = -I$(ATHEME)/include -I$(ATHEME)/libmowgli-2/src/libmowgli -DDATADIR=\"$(PREFIX)/etc\"

SOURCES = \
	freenode_prevent_registration.c

SCRIPTS = \
	gmsserv.pl

MODULES = $(patsubst %.c,%.so,$(SOURCES))

default: $(MODULES)

clean:
	rm -f $(MODULES)

%.so: %.c
	gcc -std=c99 -Wall -Werror -O1 -ggdb3 -fPIC $(ATHEME_CFLAGS) -shared -o$@ $<

.PHONY: install

install: $(MODULES)
	install -d $(PREFIX)/modules/$(SUBDIR)
	install -t $(PREFIX)/modules/$(SUBDIR) $(SCRIPTS)
	install -t $(PREFIX)/modules/$(SUBDIR) $(MODULES)
