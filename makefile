# From source markup files (.rst, .md),
# generate output files (.html, .txt, .pdf).
#
# From all meta.json, generate one $MWK/catalog.json.
# From all files, generate one $MWK/sitemap.html.
#
# https://github.com/a3n/miki                                               

# Check if MWK is set.
mwk_stripped := $(strip $(MWK))
ifeq ($(mwk_stripped),)
$(error You must set environment variable MWK \
to the top directory of your wiki, MWK is blank or unset)
endif

# Check if MWK is a directory.
mwk_dir := $(shell find "$(MWK)" -type d -wholename "$(MWK)")
ifneq ($(MWK),$(mwk_dir))
$(error You must set environment variable MWK \
to the top directory of your wiki, MWK = $(MWK))
endif

##########################
### Create file lists. ###

# Find all meta.json files, for building a catalog.
META := $(shell find $(MWK) -type f -name "meta.json")
CATA := $(MWK)/catalog.json
SITE := $(MWK)/sitemap.html

# reStructuredText
# Find all .rst files at $MWK and below.
# Create corresponding target lists for .html, .txt, .pdf.
RST := $(shell find $(MWK) -type f -name "*.rst")
RHTML := $(RST:.rst=.html)
RTEXT := $(RST:.rst=.txt)
RPDF := $(RST:.rst=.pdf)

# Markdown
# Find all .md files at $MWK and below.
# Create corresponding target lists for .html, .txt, .pdf.
MD := $(shell find $(MWK) -type f -name "*.md")
MHTML := $(MD:.md=.html)
MTEXT := $(MD:.md=.txt)
MPDF := $(MD:.md=.pdf)

HTML := $(RHTML) $(MHTML) $(AHTML) $(CATA) $(SITE)
TEXT := $(RTEXT) $(MTEXT) $(ATEXT)
PDF := $(RPDF) $(MPDF) $(APDF)

ALL := $(sort $(HTML) $(TEXT) $(PDF))
ALL_SOURCE := $(sort $(RST) $(MD))

#####################
### Target rules. ###

html: $(HTML)

text: $(TEXT)

pdf: $(PDF)

all: $(ALL)

catalog: $(CATA)

sitemap: $(SITE)

# Clean all the things!
clean:
	@rm -f $(ALL)
	@echo cleaned

print:
	@echo "All source:"
	@echo $(ALL_SOURCE) |tr " " "\n"
	@echo $(sort $(META)) |tr " " "\n"
	@echo "All targets:"
	@echo $(ALL) |tr " " "\n"

goodlinks: $(HTML)
	@ echo
	# Any local links found in files, and the links exist in $(MWK)
	#
	@for lk in $$(grep -onE 'href="[^"]*"' $$(find $$MWK -type f) |grep "href=\"/home") ; do \
	    f=$$(echo $$lk |cut -d ":" -f 3) ; \
	    f=$$(echo $$f |cut -d "\"" -f 2) ; \
	    lynx -dump "$$f" 2>1 >/dev/null && echo $$lk ; \
	done |sort -u

badlinks: $(HTML)
	@ echo
	# Any local links found in files, and the links DO NOT EXIST in $(MWK)
	# From the file on the left of ':', determine the source file,
	# and fix the link.
	#
	@for lk in $$(grep -onE 'href="[^"]*"' $$(find $$MWK -type f) |grep "href=\"/home") ; do \
	    f=$$(echo $$lk |cut -d ":" -f 3) ; \
	    f=$$(echo $$f |cut -d "\"" -f 2) ; \
	    lynx -dump "$$f" 2>1 >/dev/null || echo $$lk ; \
	done |sort -u


#############################
### File generation rules ###

# The following "MWK_TO..." make variables:
# - Change any "$MWK...markupSuffix"
#   to "file://MWKexpansion...outputSuffix"
# - Expand any lone $MWK instances.
# - Remove any ascii null characters found.

MWK_TO_HTML_SED = ' {\
s|$$MWK\(.*\)\.md|file://$(MWK)\1.html|g ; \
s|$$MWK\(.*\)\.rst|file://$(MWK)\1.html|g ; \
s|$$MWK|$(MWK)|g ; \
s|\x00||g } '

MWK_TO_PDF_SED = ' {\
s|$$MWK\(.*\)\.md|file://$(MWK)\1.pdf|g ; \
s|$$MWK\(.*\)\.rst|file://$(MWK)\1.pdf|g ; \
s|$$MWK|$(MWK)|g ; \
s|\x00||g } '

MWK_TO_TXT_SED = ' {\
s|$$MWK\(.*\)\.md|file://$(MWK)\1.txt|g ; \
s|$$MWK\(.*\)\.rst|file://$(MWK)\1.txt|g ; \
s|$$MWK|$(MWK)|g ; \
s|\x00||g } '

%.html: %.rst
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_HTML_SED) $< \
	|rst2html --tab-width=4 > $@

%.pdf: %.rst
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_PDF_SED) $< \
	|rst2pdf -o $@ >/dev/null

%.txt: %.rst
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_TXT_SED) $< \
	|rst2html --tab-width=4 > $@
	lynx -dump -force_html $@ > $@.txt
	rm -f $@; mv $@.txt $@

%.html: %.md
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_HTML_SED) $< \
	|pandoc -s --toc -f markdown -t html -o $@

%.pdf: %.md
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_PDF_SED) $< \
	|pandoc -s --toc -V geometry:margin=1in -o $@

%.txt: %.md
	@ echo
	# $< to $@
	#
	sed $(MWK_TO_TXT_SED) $< \
	|pandoc -s --toc -f markdown -t html -o $@
	lynx -dump -force_html $@ > $@.txt
	rm -f $@; mv $@.txt $@

# Generate the media catalog.
#
$(CATA): $(META)
	@ echo
	# Catalog: All meta.json to $@
	#
	cat $(META) |sed -e "s|\x24MWK|file://$(MWK)|" |jq --slurp '.' > $(CATA)

	@ echo
	# Catalog: Sort and group json objects in $@
	#
	cat $(CATA) |jq \
	  'sort_by(.title) |group_by(.categoryPrimary, .categorySecondary)' \
	  > $(CATA).tmp && mv $(CATA).tmp $(CATA)

# Generate the sitemap.
#
$(SITE):
	@echo
	# Generate sitemap.
	#
	tree -H $(MWK) -T "$(MWK) sitemap" $(MWK) > $@
