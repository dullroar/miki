---
title: 'mdStarter'
subtitle: 'A starter file to copy into a new markup file'
---

*NOTE*: *markdown* does not have a Table of Contents feature.
However, *Miki markdown* files will generate a ToC,
because we use pandoc, which figures it out.

# What is this?

`mdStarter.md` is a *markdown* (md) markup file.
All of your md filenames must end in `.md`,
so that the `makefile` can find them for target generation.

You can copy this file to a new markup file (or not), to get started.
It has a small amount of boiler plate,
and reminders on how to write md links in *Miki*.

Keep and change the content that you need, delete the rest.

`mdStarter.html` is the result of running `mwk`,
which calls the `makefile`,
which converts the markup file to html.
You should run `mwk`
and compare `mdStarter.html` with `mdStarter.md`.

Use this file, or refer to it, or ignore it, or delete it.

# How to Write Links

You can write links however you're used to writing them
in your markup language.
There are two conventions in Miki
that can make markup file creation and maintenance
a little more pleasant and productive.

*Vim* and *Emacs*, and probably other text editors,
can open the file under the cursor,
and they understand environment variables in filenames.
This is convenient for jumping from markup file to markup file
when you're creating or maintaining markup files
with a text editor.

Write your links with
`$ MWK`
at the front of the link, rather than `file:///home...` .
It will be translated to the expanded value of that environment variable
during output file generation.
This makes it easy to move or otherwise rename your wiki
without breaking links.

Use the markup suffix of the target file (`.md`)
at the end of a link, rather than `.html`.
It will be translated to the correct suffix, e.g. `.html` or `.pdf`
during output file generation.
This way when you "jump to file" in your editor,
you'll go to the markup file, not the html file.

Or ignore all this and do what you like.

* Bare wiki links:

| *Written as*
|   -> *Translated to*


    $ MWK/a/b/f.adoc
      -> $MWK/a/b/f.adoc

    $ MWK/a/b/f.md
      -> $MWK/a/b/f.md

    $ MWK/a/b/f.rst
      -> $MWK/a/b/f.rst

* md formatted links:

In an md markup file, you must write formatted links according
to the type of markup you're using.
However, you can link to anything.
You might be writing an md file, and want to link to an adoc file.
That's fine, as long as you use the link formatting for the
markup language of the current file.

| *Written as*
|   -> *Translated to*

    [a optional link text]($ MWK/a/b/f.adoc) 
      -> [a optional link text]($MWK/a/b/f.adoc) 

    [m optional link text]($ MWK/a/b/f.md) 
      -> [m optional link text]($MWK/a/b/f.md) 

    [r optional link text]($ MWK/a/b/f.rst) 
      -> [r optional link text]($MWK/a/b/f.rst) 

* Non-markup links.

To link to an html or other file in your wiki that you've copied in
or created without using a markup file,
or to files on your system that are outside your wiki,
or to the web,
use the normal suffix at the end, e.g. `.html`.

You can still use $ MWK for the front part of links to files in your wiki.

| *Written as*
|   -> *Translated to*

    [link to a copied html file in this wiki]($ MWK/a/b/c.html)
      -> [link to a copied html file in this wiki](file://$MWK/a/b/c.html)

    [link to something outside this wiki](file:///some/dir/someFile.html)
      -> No change, normal md transformation applies.

    Bare link: file:///some/dir/someFile.html
      -> No change, normal md transformation applies.

    [Le Web](http://example.com/exampleFile.html)
      -> No change, normal md transformation applies.

    Bare web link: http://example.com/exampleFile.html
      -> No change, normal md transformation applies.

## How $ MWK and links are expanded

The `makefile` expands all lone occurrences of `$ MWK`
into the value of that environment variable:

| `$MWK`

The `makefile`  translates anything on one line in the markup file
that looks like a markup link, e.g:

| `$ MWK ... text ... .md` (or other markup suffix)

into:

| `$MWK ... text ... .md`

If you inhibit translating just the suffix part of a link (see below),
then the `$ MWK` part is expanded as a lone occurrence,
since there is no occurrence of a markup suffix to the right of it:

| `$MWK ... text ... . md`

That's useful to show the location of the source of a file,
for example,
rather than the location of its generated output file.
See for example:

| `$ MWK/ExampleTopic/TopicX/mdTopicX.md`

and

| `$ MWK/ExampleTopic/TopicX/mdTopicX.html`

which points to its own source.

## How to inhibit $ MWK and link expansion

You might not care about this,
unless you want instances of links or $ MWK
to appear unexpanded in your output files.
Like in the previous sentence.
This file talks about $ MWK; your files likely only use it.

> `NOTE`: in the examples in this section,
> where a control character is shown, e.g. `^@`,
> I'm using two printable characters to represent what is really
> a single non-printable control character, ascii null in this case.
> This is how your editor will appear to display it.
> 
> The end of this section shows how to insert the null character.

To prevent expanding lone occurrences of `$ MWK`, insert an
[ascii null](https://en.wikipedia.org/wiki/Null_character)
between the `$` and the `M`:

`$^@MWK`

To prevent expanding a markup link, e.g
`$ MWK/some/file.md`,
insert a null into the `$ MWK` part of the link:

`$^@MWK/some/file.md`

To prevent translating just the suffix part of a link
from `.md` to a target suffix,
insert a null between the dot and the suffix letters.
The `$ MWK` part of the link will still be expanded,
but only to its value, not to a `file://` link:

`$ MWK/some/file.^@md`

becomes

`$MWK/some/file. md`

Inserting null changes the sequence of characters to something
that the `makefile` isn't looking for, and will leave as-is,
It's an unlikely character, so it's easy and safe to strip out
before the final output file generation.

### How to insert control characters into text

* `Vim`: In insert mode: '$', 'ctrl-v', '0', 'M', 'W', 'K'

    $ ctrl-v 0 M W K

* `Emacs`: '$', 'ctrl-q', '0', 'M', 'W', 'K'

    $ ctrl-q 0 M W K

* Nano: '$', 'escKey', 'v', '000000', 'M', 'W', 'K'

    * That's six zeroes, unicode for the NULL character.

    $ escKey v 000000 M W K

If you want to use this technique, you'll need to use the null character,
because the `makefile` strips that out specifically,
after variable and link expansion and before final output file generation.

Try it on a small file with your editor. Notice '`\0`' in the `od` output:

    $ vim demo.txt
    
    $ cat demo.txt
    Demo $ MWK Demo
    
    $ od -c demo.txt
    0000000   D   e   m   o       $  \0   M   W   K       D   e   m   o  \n
    0000020


How Miki Processes Links
------------------------

If you're curious, but don't want to read the `makefile` ...

    $ mwk
    [
      - makefile notices that an html file needs to be generated.
      - Run sed on markup file:
        - Replace all $ MWK...text...markupSuffix with
          file://$MWK...text...html
        - Replace all lone $ MWK with its value.
        - Remove all ascii null characters.
      - Run markup generator (e.g. pandoc) on the above.
    ]

# Comments in Markup Files

I sometimes write comments in my markup files,
not intended for html or other output.
I might make comments to remind me of things:

  - ToDo
  - FixThis
  - Play more Minecraft.

*markdown* doesn't have comments, but you can pass html through
to the output file.

So write html comments in your md files;
they won't be seen when viewing a page in the browser,
but you will see them when viewing source in the browser.

An md comment appears in the markup file as follows:

    <!--
    This is a comment, and will not show up as visible on a generated page.
    It will show up as an html comment, and you can see it if you
    View Source or edit the html file.
    -->

That same comment follows, properly placed,
and so not directly visible in the output.

... `<crickets>` ...

<!--
This is a comment, and will not show up as visible on a generated page.
It will show up as an html comment, and you can see it if you
View Source or edit the html file.
-->
