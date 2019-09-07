prefix ?= /usr
bindir ?= $(prefix)/bin
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man

INSTALL=install
HELP2MAN=help2man

all: gla11y.1

gla11y.1: gla11y
	$(HELP2MAN) -N -n "Check accessibility of glade .ui files" ./$< > $@

check:
	$(MAKE) -C regress/

install: gla11y.1
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) gla11y $(DESTDIR)$(bindir)/gla11y
	$(INSTALL) -d $(DESTDIR)$(mandir)/man1
	$(INSTALL) -m 644 gla11y.1 $(DESTDIR)$(mandir)/man1/gla11y.1

clean:
	rm -f gla11y.1
