da\_html\_escape.cr
============

DA\_HTML is a Crystal shard to escape/unescape HTML.

A much better shard: [https://github.com/kostya/myhtml](https://github.com/kostya/myhtml)
More info: [https://github.com/kostya/entities/pull/1#issuecomment-330849435](https://github.com/kostya/entities/pull/1#issuecomment-330849435)

If you are still curious about this shard:
==========================================

HTML entity decoding is done by the [kostya/myhtml](https://github.com/kostya/myhtml) shard.

Encoding characters into HTML entities is done by taking the codepoints and converting them
to hexadecimal HTML entities. I ported segments of [HTMLEntities by Paul Battley](https://github.com/threedaymonk/htmlentities)
for the encoding and most of the specs/tests.

This shard escapes all non-ASCII characters to hexadecimal only.
No named or decimal entities are used when escaping.  This shard is also useless for XML
entities.

I use this because Crystal's standard lib's [HTML](https://crystal-lang.org/api/master/HTML.html)
only escapes a few characters. I decide to play it extra safe
and escape all non-ASCII characters.

Also, [HTML.unescape and XML.parse\_html](https://github.com/crystal-lang/crystal/pull/3409)
does not fully unescape certain chars. [kostya/myhtml](https://github.com/kostya/myhtml) is the only one that
properly unescapes the following into `<` brackets:

```crystal
    bracket = "
      < &lt &lt; &LT &LT; &#60 &#060 &#0060
      &#00060 &#000060 &#0000060 &#60; &#060; &#0060; &#00060;
      &#000060; &#0000060; &#x3c &#x03c &#x003c &#x0003c &#x00003c
      &#x000003c &#x3c; &#x03c; &#x003c; &#x0003c; &#x00003c;
      &#x000003c; &#X3c &#X03c &#X003c &#X0003c &#X00003c &#X000003c
      &#X3c; &#X03c; &#X003c; &#X0003c; &#X00003c; &#X000003c;
      &#x3C &#x03C &#x003C &#x0003C &#x00003C &#x000003C &#x3C; &#x03C;
      &#x003C; &#x0003C; &#x00003C; &#x000003C; &#X3C &#X03C
      &#X003C &#X0003C &#X00003C &#X000003C &#X3C; &#X03C; &#X003C; &#X0003C;
      &#X00003C; &#X000003C; \x3c \x3C \u003c \u003C
    "
```


Notes:
=========

Further security info:
[OSWAP: Cross Site Prevention](https://goo.gl/Rka7pX)

List of hexadecimal entities with counterpart codepoints:
* [http://www.howtocreate.co.uk/sidehtmlentity.html](http://www.howtocreate.co.uk/sidehtmlentity.html)
* [https://dev.w3.org/html5/html-author/charref](https://dev.w3.org/html5/html-author/charref)
* Multibyte chars: [https://www.w3schools.com/charsets/ref_html_entities_v.asp](https://www.w3schools.com/charsets/ref_html_entities_v.asp)
* Convert chars: [https://r12a.github.io/apps/conversion/](https://r12a.github.io/apps/conversion/)

Searchable list of entities:
[http://www.fileformat.info/info/unicode/char/0000/index.htm](http://www.fileformat.info/info/unicode/char/0000/index.htm)

Usage:
=======

```crystal
  require "da_html_escape"

  # Escape unsafe/non-ASCII codepoints using hexadecimal entities:
  raw = "<élan>"
  DA_HTML_ESCAPE.escape(raw) # => "&#x3c;&#xe9;lan&#x3e;"

  # Unescaping:
  escaped = "&eacute;lan"
  DA_HTML_ESCAPE.unescape_once(escaped) # => "élan"

  # :unescape! keeps looping until it can no
  # longer unescape any more:
  escaped = "&amp;amp;amp;eacute;lan"
  DA_HTML_ESCAPE.unescape!(escaped) # => "élan"
```

## Licence

This code is free to use under the terms of the MIT licence. See the file
[LICENSE](https://github.com/da99/da_html_escape.cr/blob/master/LICENSE) for more details.


## Useless Benchmarks:

NOTE: Encoding is twice as slow as using `HTML.escape`
from the Crystal standard library. The main reason is
because `DA_HTML_ESCAPE` replaces control characters with spaces
and non-ASCII chars with hexadecimal HTML entities.

```
$ crystal run perf/benchmark.cr --release --no-debug
  # 100 iterations
  :escape           0.400000   0.030000   0.430000 (  0.466291)
  :unescape_once    0.760000   0.000000   0.760000 (  0.822908)
  :unescape!        1.810000   0.010000   1.820000 (  2.019186)

$ neofetch
  CPU: AMD Athlon 5350 APU with Radeon R3 (4) @ 2.050GHz
  Memory: 1555MiB / 7934MiB
```
