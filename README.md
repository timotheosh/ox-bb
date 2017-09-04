ox-s9y - Serendipity blog export for Org
========================================

This tries to be an [Org](http://orgmode) export backend to generate
HTML code suitable to be imported as an article into the
[Serendipity](https://docs.s9y.org) (s9y) blog system.  Code blocks
will be rendered via the [GeSHI](http://qbnz.com/highlighter/) plugin
in s9y.

todo
----

- restrict export to the contents of the `<body>` tag
- export code blocks in GeSHi syntax
- remove all CSS classes from the generated HTML tags

done
----

- add export commands to the export menu (using default `ox-html` export)
