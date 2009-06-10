
PREFIX ?= /home/users/stephen/bins/atheme
ATHEME ?= /home/users/stephen/scm/atheme

SRVNAME = groupserv

ATHEME_CFLAGS = -I$(ATHEME)/include -I$(ATHEME)/libmowgli/src/libmowgli -DDATADIR=\"$(PREFIX)/etc\"

SOURCES = $(wildcard *.c)
MODULES = $(patsubst %.c,%.so,$(SOURCES))

default: $(MODULES)

clean:
	rm -f $(MODULES)

%.so: %.c
	gcc -std=c99 -Wall -Werror -O1 -ggdb3 -fPIC $(ATHEME_CFLAGS) -shared -o$@ $<

.PHONY: install

install: $(MODULES)
	install -d $(PREFIX)/modules/$(SRVNAME)
	install -t $(PREFIX)/modules/$(SRVNAME) $(MODULES)
#	install -d $(PREFIX)/help/$(SRVNAME)
#	install -t $(PREFIX)/help/$(SRVNAME) help/*




