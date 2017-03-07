
# From .rst or .md, generate .html, .txt, .pdf

ifeq ($(MWK),)
  $(error You must set environment variable MWK\
 to the top directory of your wiki)
endif

##########################
### Create file lists. ###

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

HTML := $(RHTML) $(MHTML)
TEXT := $(RTEXT) $(MTEXT)
PDF := $(RPDF) $(MPDF)

# Find all meta.json files, for building a catalog.
META := $(shell find $(MWK) -type f -name "meta.json")
CATA := $(MWK)/catalog.json

ALL := $(sort $(HTML) $(TEXT) $(PDF))
ALL_SOURCE := $(sort $(RST) $(MD))

#########################
### List-based rules. ###

# Generate .html files from all .rst and .md files.
html: $(HTML) catalog

# Generate plain .txt files from all .rst and .md files.
text: $(TEXT)

# Generate PDF files from all .rst and .md files.
pdf: $(PDF)

# Generate all the things.
all: $(ALL) catalog

# Generate a catalog of all meta.json files.
catalog: $(CATA)

# Clean all the things!
clean:
	@rm -f $(ALL)
	@echo cleaned

print:
	@echo "All source:"
	@echo $(ALL_SOURCE) |tr " " "\n"
	@echo "All targets:"
	@echo $(ALL) |tr " " "\n"

#######################
### File type rules ###

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
	$< |rst2html --tab-width=4 > $@

%.pdf: %.rst
	@ echo
	@# ">/dev/null" because rst2pdf is really chatty.
	# $< to $@
	#
	sed -e "s|<\x24MWK/|<$(MWK)/|" \
	    -e "s|\.rst>\`_|.html>\`_|" \
	    -e "s|\.md>\`_|.html>\`_|" \
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
	$< |pandoc -s --toc -f markdown -t html -o $@

%.pdf: %.md
	@ echo
	# $< to $@
	#
	sed -e "s|\]\x28\x24MWK/|\]\x28$(MWK)/|" \
	    -e "s|\.md\x29|.html\x29|" \
	    -e "s|\.rst\x29|.html\x29|" \
	$< |pandoc -s --toc -V geometry:margin=1in -o $@

%.txt: %.html
	@ echo
	# $< to $@
	#
	lynx -dump $< > $@

$(CATA): $(META)
	@ echo
	# Collect the json objects from all meta.json files
	# into a single array of json objects.
	#
	cat $(META) |sed -e "s|\x24MWK|file://$(MWK)|" |jq --slurp '.' > $(CATA)
	@ echo
	# Group json objects by categories, sorted within the groups.
	#
	cat $(CATA) |jq \
	  'sort_by(.title) |group_by(.categoryPrimary, .categorySecondary)' \
	  > $(CATA).tmp && mv $(CATA).tmp $(CATA)
