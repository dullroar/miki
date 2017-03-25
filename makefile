# From .rst or .md files, generate respective .html, .txt, .pdf
# From all meta.json, generate one $MWK/catalog.json
# From all files, generate one $MWK/sitemap.html
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

# Find all .rst files at $MWK and below.
# Create corresponding target lists for .html, .txt, .pdf.
RST := $(shell find $(MWK) -type f -name "*.rst")
RHTML := $(RST:.rst=.html)
RTEXT := $(RST:.rst=.txt)
RPDF := $(RST:.rst=.pdf)

# Find all .md files at $MWK and below.
# Create corresponding target lists for .html, .txt, .pdf.
MD := $(shell find $(MWK) -type f -name "*.md")
MHTML := $(MD:.md=.html)
MTEXT := $(MD:.md=.txt)
MPDF := $(MD:.md=.pdf)

HTML := $(RHTML) $(MHTML) $(CATA) $(SITE)
TEXT := $(RTEXT) $(MTEXT)
PDF := $(RPDF) $(MPDF)

ALL := $(sort $(HTML) $(TEXT) $(PDF))
ALL_SOURCE := $(sort $(RST) $(MD))

#####################
### Target rules. ###

# Generate .html files from all .rst and .md files.
html: $(HTML)

# Generate plain .txt files from all .rst and .md files.
text: $(TEXT)

# Generate PDF files from all .rst and .md files.
pdf: $(PDF)

# Generate all the things.
all: $(ALL)

# Generate a catalog of all meta.json files.
catalog: $(CATA)

# Generate sitemap
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

# goodlinks and badlinks only differ on their second lines:
# "&&" vs "||"
goodlinks: $(HTML)
	@ echo
	# Any local links found in files, and the links exist in $(MWK)
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
	@for lk in $$(grep -onE 'href="[^"]*"' $$(find $$MWK -type f) |grep "href=\"/home") ; do \
	    f=$$(echo $$lk |cut -d ":" -f 3) ; \
	    f=$$(echo $$f |cut -d "\"" -f 2) ; \
	    lynx -dump "$$f" 2>1 >/dev/null || echo $$lk ; \
	done |sort -u


#############################
### File generation rules ###

# - Expand $(MWK).
# - Change .rst and .md to .html.
# - Then run rst2html.
%.html: %.rst
	@ echo
	# $< to $@
	#
	sed -e "s|<\x24MWK/|<$(MWK)/|" \
	    -e "s|\.rst>\`_|.html>\`_|" \
	    -e "s|\.md>\`_|.html>\`_|" \
	    -e "s|\x24MWK|file://$(MWK)|" \
	$< |rst2html --tab-width=4 > $@

%.pdf: %.rst
	@ echo
	@# ">/dev/null" because rst2pdf is really chatty.
	# $< to $@
	#
	sed -e "s|<\x24MWK/|<$(MWK)/|" \
	    -e "s|\.rst>\`_|.html>\`_|" \
	    -e "s|\.md>\`_|.html>\`_|" \
	    -e "s|\x24MWK|file://$(MWK)|" \
	$< |rst2pdf -o $@ >/dev/null

# - Expand $(MWK).
# - Change .rst and .md to .html.
# - Then run markdown.
%.html: %.md
	@ echo
	# $< to $@
	#
	sed -e "s|\]\x28\x24MWK/|\]\x28$(MWK)/|" \
	    -e "s|\.md\x29|.html\x29|" \
	    -e "s|\.rst\x29|.html\x29|" \
	    -e "s|\x24MWK|file://$(MWK)|" \
	$< |pandoc -s --toc -f markdown -t html -o $@

%.pdf: %.md
	@ echo
	# $< to $@
	#
	sed -e "s|\]\x28\x24MWK/|\]\x28$(MWK)/|" \
	    -e "s|\.md\x29|.html\x29|" \
	    -e "s|\.rst\x29|.html\x29|" \
	    -e "s|\x24MWK|file://$(MWK)|" \
	$< |pandoc -s --toc -V geometry:margin=1in -o $@

%.txt: %.html
	@ echo
	# $< to $@
	#
	lynx -dump $< > $@

$(CATA): $(META)
	@ echo
	# All meta.json to $@
	#
	cat $(META) |sed -e "s|\x24MWK|file://$(MWK)|" |jq --slurp '.' > $(CATA)

	@ echo
	# Sort and group json objects in $@
	#
	cat $(CATA) |jq \
	  'sort_by(.title) |group_by(.categoryPrimary, .categorySecondary)' \
	  > $(CATA).tmp && mv $(CATA).tmp $(CATA)

$(SITE):
	@echo
	# Generate sitemap.
	#
	tree -H $(MWK) -T "$(MWK) sitemap" $(MWK) > $@
