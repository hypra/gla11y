prefix ?= /usr
bindir ?= $(prefix)/bin
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man

INSTALL=install

all: gla11y.1

gla11y.1: gla11y
	help2man -N ./$< > $@

check:
	$(MAKE) -C regress/

install: gla11y.1
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) gla11y $(DESTDIR)$(bindir)/gla11y
	$(INSTALL) -d $(DESTDIR)$(mandir)
	$(INSTALL) -m 644 gla11y.1 $(DESTDIR)$(mandir)/gla11y.1
