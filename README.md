GLA11Y(1) - General Commands Manual

# NAME

**gla11y** - check accessibility of glade widgets

# SYNOPSIS

**gla11y**
\[**-pW**]
\[**-i**&nbsp;*widgets*]
\[**-l**&nbsp;*log*&nbsp;\[**-a**]]
\[*file&nbsp;...*]

# DESCRIPTION

The
**gla11y**
utility check if
*file*
respect glade accessibility rules.
It prints messages for every error it encounters.

The options are as follows:

**-a**

> Append messages to
> *log*
> instead of printing them to stdout.
> This option has no effect unless
> **-l**
> is specified.

**-i** *widgets*

> Do not check elements whose class is listed in
> *widgets*.
> By default the following widgets are ignored:
> *GtkBox*,
> *GtkVBox*.

**-I**

> Do not ignore any widget.

**-l** *log*

> Do not print messages already present in
> *log*.
> This option implies
> **-p**.

**-p**

> Print class paths instead of line numbers in messages.

**-W**

> Make all warnings into errors.

# EXIT STATUS

The **gla11y** utility exits&#160;0 on success, and&#160;&gt;0 if an error occurs.

# EXAMPLES

To check all the widgets but
*GtkLabel*
and
*AtkObject*
in the file sortdialog.ui:

	gla11y -i GtkLabel,AtkObject sortdialog.ui

To check if new errors have been introduced in sortdialog.ui since the
generation of
*error.log*:

	gla11y -l error.log sortdialog.ui
