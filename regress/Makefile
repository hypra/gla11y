
GLA11Y ?=	../gla11y
TESTS =		000-multiple_a11y_children \
		001-non_existing_labelled-by \
		002-multiple_label-for \
		003-multiple_mnemonic_widget \
		004-broken_label-for \
		005-broken_mnemonic_widget \
		006-empty_GtkLabel \
		007-multiple_label-for \
		008-more_than_one_mnemonic_widget

LOGTESTS =	100-multiple_a11y_children

all: $(TESTS) $(LOGTESTS)

$(TESTS):
	$(GLA11Y) $@.ui | diff -u $@.ok /dev/stdin

$(LOGTESTS):
	$(GLA11Y) -s $@.suppr $@.ui | diff -u $@.ok /dev/stdin

.PHONY: all $(TESTS) $(LOGTESTS)

