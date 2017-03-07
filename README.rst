<<<<<<<<<<<<<<<<<<<
Miki: Makefile Wiki
<<<<<<<<<<<<<<<<<<<

Minimal makefile-based personal wiki
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.. meta::
    :description: https://github.com/a3n/miki
	 Miki: minimal makefile-based personal wiki.

Write wiki files in
`reStructuredText <https://en.wikipedia.org/wiki/ReStructuredText>`_ (reST)
or (`pandoc <http://pandoc.org/MANUAL.html#pandocs-markdown>`_)
`markdown <https://en.wikipedia.org/wiki/Markdown>`_ files.
Run ``make`` to generate html, text and/or pdf output files.

Write links that end in ".rst" or ".md" in those source files,
not ".html",
allowing easy navigation between source files
from within your text editor.

The included ``makefile`` translates links ending in ".rst" or ".md"
in the source files to ".html" in the output files.

There is no sofware here, only an included makefile,
an optional included shell script,
and a couple of link writing conventions.

For people who are already writing reST or markdown files,
and using a capable programmer's editor like Vim, emacs or equivalent,
this is exactly the sort of thing they'll like.

.. contents::

How
===

* Copy the ``makefile`` to the top of the directory where your wiki will be.

* In your shell's ``~/.*rc`` file, .e.g. ``~/.bashrc``

  * ``export MWK=/path/to/your/wiki``
  * Then to actually set the variable,
    start a new shell, or do the export in the current shell.
  * Check it: ``$ echo $MWK``

* Write your .rst and/or .md source files.
* Run ``make`` to generate output files.

Since there is only the one ``makefile``,
you need to run ``make`` from the top of your MWK directory,
or ``make -f $MWK/makefile`` from anywhere.

For convenience, put the included optional ``mwk`` script on your path
and make it executable.
You can then run ``mwk clean html``, for example, from anywhere::

  $ cat ~/bin/mwk
  #! /usr/bin/env bash

  make -f $MWK/makefile $*

  $ chmod ug+x ~/bin/mwk

The Catalog Target
------------------

I've found it useful to reference my local ebooks and other resources
in my use of miki.
I've also found it useful to keep those resources in my miki.

Each wiki topic only references books and resources relevant to that topic.
But it's nice to have a single listing of all available resources.

``mwk catalog`` or ``mwk html`` will look for all meta.json files
in the wiki, and create catalog.json at the top of the wiki.

All the objects found in the meta.json files are combined into one list,
sorted by title and grouped by category.

As catalog.json is just a text file, it's viewable in your browser.
If your browser displays json "live," the links will be clickable.
I use the Firefox addon https://addons.mozilla.org/en-us/firefox/addon/jsonview/

* Similar to the mwk script, copy the newmeta script to somewhere on your path,
  like ~/bin. This script creates a meta.json file in the current directory.
* I keep my books and other resources in $MWK/Books,
  in individual subdirectories for each book.
  Each subdirectory has a meta.json file.
* To create a new meta.json file:

::

  $ mkdir $MWK/Books/MyNewBook
  $ cd $MWK/Books/MyNewBook
  $ cp /path/to/new/book/book.pdf .
  $ newmeta book.pdf

* Now edit the title, categories and other fields
  in the generated meta.json.
  The link to the book.pdf is already created.
* To update the catalog, run any of:

::

  $ mwk
  $ mwk all
  $ mwk html
  $ mwk catalog

Requirements:

* Depends on the `jq` utility, probably available in your OS repository.

  * Or you can get it from github: https://github.com/stedolan/jq

* Each meta.json file must have one or more json objects.
* If there is more than one json object in a meta.json file,
  they must `not` be separated by a comma.

  * See $MWK/Books/BeejsGuides/meta.json for a multi-object example.

* Your meta.json objects can have any valid json within them,
  but it's recommended to have at least title, categoryPrimary and
  categorySecondary, as the makefile sorts and groups by those fields.

newmeta will not generate a meta.json file if one already exists
in the current directory.

If the argument to newmeta does not exist,
newmeta will issue a warning but generate meta.json anyway.

If you don't want to link to anything, just supply . or "" as the argument,
and then delete the link field with your editor.

Add any legal json you like to your generated meta.json file.
See the examples in the Books subdirectory of this repo.

Note that there are no actual book files in the Books subdirectories
of this repo; I didn't want to include binaries in the repo.
Normally you would have your files alongside your meta.json files
in your Books subdirectories. I included a source field for each
item in the Books examples, if you want to go looking.

Writing Links in Your .rst and .md source files
===============================================

In your .rst files, instead of writing this::

  Back to `readme <../README.html>`__
  # or
  Back to `readme </path/to/your/wiki/README.html>`__

write this::

  Back to `readme <$MWK/README.rst>`__
  # or
  Back to `readme <$MWK/README.md>`__

* Those are anonymous links (double underscore),
  so that you can write out the same link more than once
  in a .rst file.
* ``$MWK`` at the front is understood by Vim,
  so that you can follow the link in Vim.
* ``$MWK`` is expanded by the ``makefile`` to its value.

In your .md files, instead of writing this::

  Back to [readme](../README.html)
  # or
  Back to [readme](/path/to/your/wiki/README.html)

write this::

  Back to [readme]($MWK/README.rst)
  # or
  Back to [readme]($MWK/README.md)

Note that in a single wiki you might have
both reST and markdown files.
Links to both are handled,
within both kinds of source files.

Prerequisites
=============

* Linux. Probably \*bsd. Maybe cygwin or MacOS.
* make.
* docutils, for rst2html.
* rst2pdf, for rst2pdf.
* lynx, for lynx -dump to make .txt from .html.
* pandoc, for markdown to html generation.
* pandoc and latex, for markdown to pdf generation.
  
  * I installed texlive-latex-base, lmodern,
    and anything else that was complained about while generating files.
  * The names of packages on your system may differ.

A Picture
=========

.. figure:: sideBySide.png
   :width: 100 %
   :target: sideBySideFull.png
   :alt: Vim and Firefox side by side.

   Vim and Firefox side by side.
