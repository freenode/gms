
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
	install -d $(PREFIX)/modules/$(SRVNAME)
	install -t $(PREFIX)/modules/$(SRVNAME) $(MODULES)
#	install -d $(PREFIX)/help/$(SRVNAME)
#	install -t $(PREFIX)/help/$(SRVNAME) help/*




