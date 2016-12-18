
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

# Find all .rst files at $MWK and below.
# Create corresponding target lists for .html, .txt, .pdf.
MD := $(shell find $(MWK) -type f -name "*.md")
MHTML := $(MD:.md=.html)
MTEXT := $(MD:.md=.txt)
MPDF := $(MD:.md=.pdf)

HTML := $(sort $(RHTML) $(MHTML))
TEXT := $(sort $(RTEXT) $(MTEXT))
PDF := $(sort $(RPDF) $(MPDF))

ALL := $(sort $(HTML) $(TEXT) $(PDF))
ALL_SOURCE := $(sort $(RST) $(MD))

#########################
### List-based rules. ###

# Generate .html files from all .rst and .md files.
html: $(HTML)

# Generate plain .txt files from all .rst and .md files.
text: $(TEXT)

# Generate PDF files from all .rst and .md files.
pdf: $(PDF)

# Generate all the things.
all: $(ALL)

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

# Prior to running rst2html:
# - Change "$MWK" if at the beginning of a link to its expanded value.
#   "\x24" is the ascii hex value of "$".
#   "|" as s-command separators because the regex and replacements have "/".
# - Change ".rst" if at the end of a link to ".html".
# - Then run rst2html.
%.html: %.rst
	sed -e "s|<\x24MWK/|<$(MWK)/|" \
	    -e "s|\.rst>\`_|.html>\`_|" \
	    -e "s|\.md>\`_|.html>\`_|" \
	$< |rst2html --tab-width=4 > $@

%.pdf: %.rst
	sed -e "s|<\x24MWK/|<$(MWK)/|" \
	    -e "s|\.rst>\`_|.html>\`_|" \
	    -e "s|\.md>\`_|.html>\`_|" \
	$< |rst2pdf -o $@

# Prior to running markdown:
# - Change "$MWK" if at the beginning of a link to its expanded value.
#   "\x24" is the ascii hex value of "$".
#   "\x28" is the ascii hex value of "(".
#   "\x29" is the ascii hex value of ")".
#   "|" as s-command separators because the regex and replacements have "/".
# - Change ".md" if at the end of a link to ".html".
# - Then run markdown.
%.html: %.md
	sed -e "s|\]\x28\x24MWK/|\]\x28$(MWK)/|" \
	    -e "s|\.md\x29|.html\x29|" \
	    -e "s|\.rst\x29|.html\x29|" \
	$< |pandoc -s -V geometry:margin=1in > $@

%.pdf: %.md
	sed -e "s|\]\x28\x24MWK/|\]\x28$(MWK)/|" \
	    -e "s|\.md\x29|.html\x29|" \
	    -e "s|\.rst\x29|.html\x29|" \
	$< |pandoc -s -V geometry:margin=1in -o $@

%.txt: %.html
	lynx -dump $< > $@
