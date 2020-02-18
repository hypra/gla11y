
GLA11Y ?=	../gla11y
TESTS =		000-multiple_a11y_children \
		001-non_existing_labelled-by \
		002-multiple_label-for \
		003-multiple_mnemonic_widget \
		004-broken_label-for \
		005-broken_mnemonic_widget \
		006-empty_GtkLabel \
		007-multiple_label-for \
		008-more_than_one_mnemonic_widget \
		010-missing_labelled-by-but-tooltip \
		011-missing_labelled-by-but-action_name \
		012-broken_labelled-by \
		013-broken_member-of \
		014-empty_GtkLabel_but_child \
		015-image_for_button \
		016-missing_labelled-by-but-labelled-frame \
		017-missing_labelled-by-without-labelled-frame \
		018-empty_GtkLabel-but-alone \
		019-missing_labelled-by-but-placeholder \
		020-button-missing-label \
		021-entry-missing-label \
		022-missing_labelled-by-but-internal-child \
		023-duplicate-id \
		024-both-label-for-and-mnemonic \
		025-multiple-labelled-by \
		026-multiple-tooltip \
		027-multiple-placeholder \
		028-multiple-label \
		029-multiple-action_name \
		030-accessible \
		031-label-for \
		032-mnemonic \
		033-missing_labelled-by-but-label \
		034-image \
		035-labelled-label \
		036-label-static \
		038-description-for \
		039-multiple_description-for

LOGTESTS =	100-multiple_a11y_children

all: $(TESTS) $(LOGTESTS)

$(TESTS):
	$(GLA11Y) $@.ui | diff -u $@.ok /dev/stdin

$(LOGTESTS):
	$(GLA11Y) -s $@.suppr $@.ui | diff -u $@.ok /dev/stdin

.PHONY: all $(TESTS) $(LOGTESTS)

