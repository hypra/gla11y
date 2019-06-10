How to fix gla11y .ui accessibility warnings
============================================

Some accessibility checks are automatically performed by the gla11y tool on
the .ui files during build time.  That will fail the build if new issues are
introduced (existing issues are typically suppressed by suppression files). Here
are explanations about warnings produced by the tool.

The tool mostly checks for labelling: GtkLabel widgets are usually used to label
another widget, and some widgets indeed do not make sense to users without
some context.  The relation is often obvious visually, but screen readers can
not guess that, so the .ui file needs to specify the widgets that labels are
intended for, otherwise the labels and the widgets are ''orphan''.  The tool
looks both for orphan labels and for orphan widgets.  Some widgets always need
labelling (e.g. GtkEntry), so warnings will always be printed for them. Others
may not always need one, and so warnings will only be printed if there are
''orphan'' labels alongside.  That means that fixing one relation between a
label and a widget may make disappear a lot of warnings about remaining orphan
widgets because there are no orphan labels that they could be labelled by any
more. Conversely, however, warnings about orphan labels are always printed, even
if there are no orphan widgets.

In case of doubt, advice can be sought for on the
gnome-accessibility-devel@gnome.org mailing list

Adding a relation between a label and a widget
==============================================

Once it is determined that a relation is missing between a label (or anything
that can be used as a label because it contains text, such as a GtkRadioButton,
a GtkCheckButton, or an image with an accessible-name) and a widget, there are
two ways to express the relation:

* The GtkLabel can probably be used to define a keyboard shortcut for the widget
(this is by large the most common case). In that case an underscore character
should be added in the label to specify the shortcut, and the following xml
bits should be added to specify the relation with the widget triggered by the
mnemonic, and the accessibility relation will be added automatically:

```
    <property name="use_underline">True</property>
    <property name="mnemonic_widget">the_widget_id</property> 
```

* If it does not make sense to set a keyboard shortcut from the label (for
instance because the label is actually for several widgets, or because it is a
GtkRadioButton or GtkCheckButton, whose keyboard shortcut is already used to
operate it), the accessibility relation should be set by hand by adding the
following xml bits to the label:

```
    <accessibility>
        <relation type="label-for" target="the_widget_id"/>
    </accessibility>
```

*and* the following bit to the widget:

```
    <accessibility>
        <relation type="labelled-by" target="the_label_id"/>
    </accessibility>
```

Yes, both ''label-for'' and ''labelled-by'' relations need to be set. An error
is emitted by the tool if they do not match.

The widgets you want to relate may not have ids yet, but you can freely add
some.

After having added a relation between a widget and a label in a .ui file, you
can check that the warning has disappeared by running by hand

    gla11y path/to/file.ui

Also, you should ideally check that labelling actually works.  A simple way is
to run

    orca -e braille-monitor

and restart the application with the new .ui file. On clicking on the widget which
has just received a label, the braille monitor should now show both the content
of the widget '''and''' the content of the label.  Orca might also be speaking a
lot, you can use insert-s to stop the speech synthesis.

Fixing existing issues
======================

For people who plan to work on fixing the existing issues (and thus emptying the
suppression files, which is the eventual goal), here is a process:

1. Pick up from the output of `*.suppr` a .ui file to fix, make sure to know how
  to reach it in the application interface to understand its semantics.
1. Move the corresponding lines away from the .suppr file (but keep them at hand
  in case some false positives should be suppressed)
1. Run make to get the uncovered list of warnings (touch the .ui file if make
  does not do anything).
1. Look over the first warnings, very often there is both a warning for an orphan
  widget and for an orphan label, and one just needs to add a relation to fix
  both at the same time.
1. Fix the issue in the .ui file (see below for the details), optionally check
  the result with a screen reader by installing the modified version (either the
  whole application, or simpler, just the single .ui file). In case of false
  positives, move the corresponding lines from the .suppr file to the .false
  file (create it if it doesn't exist yet).
1. Run make again to check that the warning went away.
1. Repeat from step 4 until gla11y does not emit any warning any more.
1. Submit these changes.
1. Restart from step 1 with another .ui file :)

Note: if you are unsure about how to fix some warning, better leave the
suppression rule in the .suppr file and let somebody else to fix the issue. It
is way better to leave a suppressed warning (which we will then know still needs
fixing) than wiping it out wrongly, which would mean hiding an accessibility
issue.

Coping with false positives
===========================

In some cases, gla11y emits warnings where there is actually no accessibility
issue (e.g. because the context is obvious, or the label does not actually
bring meaning, thus making the output heavier than useful, etc.). In that
case, one can suppress the warnings completely by putting suppression rules to
ui-a11y.false . For existing issues, the suppression
rules can be taken from the .suppr file. Otherwise, one can use

    gla11y -g suppr.false path/to/file.ui

to generate a suppression file for the whole .ui file, and from that file
copy/paste the lines corresponding to the warning to be suppressed into
ui-a11y.false .

Important: do not put a suppression rule in the .false file unless you are sure
that there is nothing to fix here. If you just happen not to know how to fix it,
keep the suppression rule in the .suppr file.

Explanations of gla11y warnings
===============================

'GtkLabel' 'labelfoo' does not specify what it labels
-----------------------------------------------------

This label (or another within the same scope) may have to be associated with a
widget which does not have a label yet.  One should thus look for the widgets
which do not have a label, and add appropriate accessibility relations.

Such orphan labels are reported even if there is no such orphan widget (but that
is not made fatal), because labels being orphan is most of the time doubtful:
labels are usually there for a reason, and not associating them with a widget
means that some meaning is rendered visually but not through screen readers.

* In some cases labels are used to convey independent information, e.g. in the
find&replace dialog to report the number of replacements. These should not be
using the LABEL role, but a STATIC role, so that screen readers know how to
report them appropriately. This can be done by adding

```
    <accessibility>
        <role type="static"/>
    </accessibility>
```

in the ```<object class="GtkLabel">```.

* In some cases there are two labels for a widget: one before the widget, and
one after the widget. For such a case we will need another "label-for-after"
accessibility relation, in addition to the standard label-for. For now, the
suppression rule should be kept in the .suppr file, so we remember to fix them
once the new relation is available.

* In some cases labels are really there for quite trivial reasons ( it is there
only for visual coherence but does not provide any meaning). In such cases a
suppression rule should be added to the .false file.

'GtkFoo' 'foobar' has no accessibility label
--------------------------------------------

This widget does not have labelling. If there are orphan labels alongside, they
may be potential candidates for labelling this widget, as described above about
the ''does not specify what is labels'' warning.  If there aren't orphan labels,
perhaps another widget can be used as a label, for instance a GtkRadioButton or
a GtkCheckButton. If there aren't candidates (because the context is obvious
visually), depending on the widget type one can set a tooltip_text property, or
a placeholder_text property, to provide a textual content that the screen reader
will be able to show to the user.

'Foo' 'foobar' has no accessibility label
-----------------------------------------

The warning mentioned above is only for Gtk widgets, for which gla11y knows
quite well which types should have labelling, and which types do not need
labelling. For application-specific widgets, gla11y does not have this
knowledge, but by default it is assumed that they need labelling.

If it is known that an application-specific widget types never needs labelling,
this knowledge can be added to the gla11y call with --widgets-ignored.

If it is known that an application-specific widget types always needs labelling
(just like a GtkEntry does), this can also be added there with --widgets-needlabel

Otherwise, the precise widgets which need labelling should be fixed as explained
in the previous section, and the precise widgets which do not need labelling
should be mentioned in a suppression line in the .false file.

'GtkLabel' 'labelfoo' has label-for, but is not labelled-by by 'GtkFoo' 'foobar' line 123
-----------------------------------------------------------------------------------------

label-for / labelled-by relations have to be set by pair: if we have a label-for
relation, we also need the corresponding labelled-by relation.  Here, one
probably just needs to add to the 'foobar' widget a 'labelled-by' relation
targetting 'labelfoo'.

'GtkFoo' 'foobar' has labelled-by, but is not label-for by 'GtkLabel' 'labelfoo' line 123
-----------------------------------------------------------------------------------------

label-for / labelled-by relations have to be set by pair: if we have a
labelled-by relation, we also need the corresponding label-for relation.  Here,
one probably just needs to add to the 'labelfoo' widget a 'label-for' relation
targetting 'foobar'.

'GtkButton' 'foobutton' does not have its own label
---------------------------------------------------

Some buttons are designed to only embed an image (e.g. an arrow). For
sight-impaired users, a label is needed to convey the information in a textual
form (e.g. notably the direction of the arrow). If a visual label actually
already exists, the label-for/labelled-by relation just needs to be added. If
no visual label already exists, one can provide extra labelling by including a
tooltip_text property in the GtkButton, for instance:

```
    <property name="tooltip_text" translatable="yes" context="mydialog|forward">Next page</property>
```

This will actually be also useful to sighted users who want to make sure of the
consequence of clicking the button.

A tooltip_text is not enough for GtkCheckButton that lacks a label property,
because that type of widget is supposed to be using its own label, and the
tooltip is only supposed to provide more lengthy explanations. Quite often
in that case, there is a visual label alongside, and one can just add the
relation. If there is really no label because the context is obvious visually,
the accessibility labelling can be provided explicitly with

```
    <child internal-child="accessible">
      <object class="AtkObject" id="checkbutton_legend-atkobject">
        <property name="AtkObject::accessible-name" translatable="yes">The label for the checkbutton</property>
      </object>
    </child>
```

'GtkEntry' 'fooentry' is referenced by multiple mnemonic_widget 'GtkLabel' 'labelfoo1' line 457 , 'GtkLabel' 'labelfoo2' line 782
---------------------------------------------------------------------------------------------------------------------------------

Several labels with mnemonics have fooentry as target. This may happen when
e.g. only one of these labels is visible at a time (but in that case one should
make sure that either the two labels are exactly the same, or the screen reader
indeed gets the proper label at the proper time) and then a suppression rule can
be added to the .false file. But otherwise it is often an indication that one of
these labels was actually mistargetted and there is an orphan widget that it was
supposed to target instead. One then just need to fix the target of labels.

'GtkTextView' 'fooentry' has both a mnemonic 'GtkLabel' 'descriptionlabel' line 152 and labelled-by relation
------------------------------------------------------------------------------------------------------------

fooentry has both a labelling relation and a label with mnemonic targetting
it. This is very doubtful, and is usually an indication that one of these labels
was actually mistargetted and there is an orphan widget that it was supposed to
target instead. One then just need to fix the target of labels.

'GtkFoo' 'foofoo' has the same id as other elements 'GtkFoo' 'foobar' line 1234
-------------------------------------------------------------------------------

foofoo and foobar have the same 'id' property, which is not allowed. The id of
one of them needs to be renamed.

'GtkFoo' 'foo' visibility conflicts with paired 'GtkBar' 'bar' line 1234
------------------------------------------------------------------------

'foo' is labelled by 'bar', and one of them has visibility enabled while the
other has visibility disabled. Visibility should be coherent for labelling to
work.
