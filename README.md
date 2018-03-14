GLA11Y
======

This tool checks accessibility of .ui files.


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
