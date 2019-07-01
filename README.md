GLA11Y (glade accessibility)
======

This tool checks accessibility of GtkBuilder .ui files
produced e.g. by glade.
It looks for various issues, and notably missing or bogus labelling
relations.

It can for instance be used in Continous Integration checks to make sure not to
introduce accessibility regressions.


This file describes the tool itself.

The HOWTO.md file describes how to fix the warnings raised by the tool.


Installation
------------

Just run

	make install

and gla11y will be installed in /usr/local/bin/ by default (can be changed by
appending prefix=... on the make command line).


Basic use
---------

The typical use is running

	gla11y $(find . -name \*.ui)

which will emit all kinds of warnings.


Using suppressions
------------------

If there are a lot of warnings for existing issues, it may be preferrable for a
start to only show new warnings: run once

	gla11y -g suppressions $(find . -name \*.ui)

to create a `suppressions' file which contains rules to suppress the warnings
found at the time of generation, and after that,

	gla11y -s suppressions $(find . -name \*.ui)

will only display warnings for new issues.

If the paths given to the tool are absolute, the -P option allows to remove a
prefix from the paths.


Application-specific widgets
----------------------------

By default, gla11y knows about Gtk standard widgets.  If the application has
its own self-baked widgets, it may be useful to teach gla11y their role, for
instance:

	gla11y --widgets-ignored +myVBox,myHBox --widgets-needlabel +myEntry $(find . -name \*.ui)

The default list of recognized widgets can be obtained with --widgets-print.


Enabling/Disabling warnings
---------------------------

Especially when starting running gla11y over a very big project with a lot
of existing warnings, it is useful to enable warnings progressively. The
--enable/disable options can be used to that end. Their effect accumulate, i.e.
each --enable/disable option overrides the effect of previous options. For
instance:

	gla11y --disable-all --enable-type undeclared-target $(find . -name \*.ui)

will only enable the undeclared-target warning type, while

	gla11y --enable-all --disable-specific no-labelled-by,GtkSpinner $(find . -name \*.ui)

will enable all warnings, except no-labelled-by for GtkSpinner widgets.


Fatal errors/warnings
---------------------

By default, only errors are fatal.  One can however fine-tune this, for instance:

	gla11y --fatal-all --not-fatal-widgets myWidget $(find . -name \*.ui)

makes all warnings (and errors) fatal except for myWiget widgets.  Conversely

	gla11y --not-fatal-all --fatal-type undeclared-target $(find . -name \*.ui)

makes all warnings and errors non-fatal, except error undeclared-target.


False positives
---------------

We have taken great care to avoid false positives, but sometimes they just can't
be detected automatically :) The simplest way to avoid them is then to blacklist
them. The -f option can be used like -s to suppress warnings, except that they
will not be reported at all any more.

This means that after creating a suppression file that silents the existing
errors to concentrate first on avoiding new accessibility issues, one can work
on warnings for existing issues by either fixing them, or moving the suppression
line from the suppression file passed to the -s option to the suppression file
passed to the -f option.


Integration in a build system
-----------------------------

To integrate the use of gla11y in a build system, you can for instance add to
configure.ac:

	AC_PATH_PROG([GLA11Y], [gla11y], [true])

and introduce a new Makefile.am rule to trigger a call to gla11y:

	ui_files = foo.ui bar.ui

	GLA11Y_OUTPUT = ui-a11y.err
	GLA11Y_SUPPR  = ui-a11y.suppr
	GLA11Y_FALSE  = ui-a11y.false

	GLA11Y_V = $(GLA11Y_V_@AM_V@)
	GLA11Y_V_ = $(GLA11Y_V_@AM_DEFAULT_V@)
	GLA11Y_V_0 = @echo "  GLA11Y  " $@;
	GLA11Y_V_1 = 

	all-local: $(GLA11Y_OUTPUT)
	$(GLA11Y_OUTPUT): $(ui_files)
		$(GLA11Y_V) $(GLA11Y) -P $(srcdir)/ -f $(srcdir)/$(GLA11Y_FALSE) -s $(srcdir)/$(GLA11Y_SUPPR) -o $@ $(ui_files:%=$(srcdir)/%)

	CLEANFILES += $(GLA11Y_OUTPUT)
	EXTRA_DIST += $(GLA11Y_SUPPR) $(GLA11Y_FALSE)

and you can generate ui-a11y.suppr from an initial call to gla11y from the
source tree:

	gla11y -g ui-a11y.suppr foo.ui bar.ui

in order to ignore the existing warnings for a start.


From then on, the gla11y call will error out if new fatal warnings are produced,
thus avoiding the corresponding accessibility regressions.  The existing
warnings can then be worked on progressively, removing the corresponding
suppression rules from the .suppr files accordingly.  In case of false positives
from the tool, they can be transferred from the .suppr file to the .false file.
See HOWTO.md for more details on the methodology, which you can point developers
to.


Credits
-------

Gla11y was developped by Hypra (http://hypra.fr/) and Martin Pieuchot under
the funding of The Document Foundation tender to implement accessibility
improvements (#201704-01)
