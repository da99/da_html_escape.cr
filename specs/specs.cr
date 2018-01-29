
require "../src/da_html_escape"
require "da_spec"

  TEST_ENTITIES_SET = [
    ["sub",     0x2282,   "⊂" ],
    ["sup",     0x2283,   "⊃" ],
    ["nsub",    0x2284,   "⊄" ],
    ["subE",    0x2ac5,   "⫅" ],
    ["sube",    0x2286,   "⊆" ],
    ["supE",    0x2ac6,   "⫆" ],
    ["supe",    0x2287,   "⊇" ],
    ["bottom",  0x22a5,   "⊥" ],
    ["perp",    0x22a5,   "⊥" ],
    ["models",  0x22a7,   "⊧" ],
    ["vDash",   0x22a8,   "⊨" ],
    ["Vdash",   0x22a9,  "⊩" ],
    ["Vvdash",  0x22aa,  "⊪" ],
    ["nvdash",  0x22ac,  "⊬" ],
    ["nvDash",  0x22ad,  "⊭" ],
    ["nVdash",  0x22ae,  "⊮" ],
    ["nsube",   0x2288,  "⊈" ],
    ["nsupe",   0x2289,  "⊉" ],
    ["subnE",   0x2acb,  "⫋" ],
    ["subne",   0x228a,  "⊊" ],
    # ["vsubnE",  0x228a,  "⫋︀" ],
    # ["vsubne",  0x228a,  "⊊" ],
    ["nsc",     0x2281,  "⊁" ],
    ["nsup",    0x2285,  "⊅" ]
    # ["b.alpha", 0x03b1,  "α" ],
    # ["b.beta",  0x03b2,  "β" ],
    # ["b.chi",   0x03c7,  "χ" ],
    # ["b.Delta", 0x0394,  "Δ" ],
  ]

extend DA_SPEC

describe ":escape" do

  it "should replace \"unit separator\" (31 ASCII) with a space" do
    assert "a " == DA_HTML_ESCAPE.escape("a\u{1f}")
  end

  it "should encode apos entity" do
    assert "&#x27;" == DA_HTML_ESCAPE.escape("'")
  end

  it "encodes README.md example" do
    assert "&#x3c;&#xe9;lan&#x3e;" == DA_HTML_ESCAPE.escape("<élan>")
  end

  it "should encode backticks" do
    assert "&#x60; a &#x60;" == DA_HTML_ESCAPE.escape("` a `")
  end # === it "should encode backticks"

  it "should encode basic entities to hexadecimal" do
    assert "&#x26;" == DA_HTML_ESCAPE.escape("&")
    assert "&#x22;" == DA_HTML_ESCAPE.escape("\"")
    assert "&#x3c;" == DA_HTML_ESCAPE.escape("<")
    assert "&#x3e;" == DA_HTML_ESCAPE.escape(">")
    assert "&#x27;" == DA_HTML_ESCAPE.escape("'")
    assert "&#x2212;" == DA_HTML_ESCAPE.escape("−")
    assert "&#x2014;" == DA_HTML_ESCAPE.escape("—")
  end

  it "should non-ASCII entities to hexadecimal" do
    assert "&#xb1;" == DA_HTML_ESCAPE.escape( "±")
    assert "&#xf0;" == DA_HTML_ESCAPE.escape( "ð")
    assert "&#x152;" == DA_HTML_ESCAPE.escape("Œ")
    assert "&#x153;" == DA_HTML_ESCAPE.escape("œ")
    assert "&#x201c;" == DA_HTML_ESCAPE.escape("“")
    assert "&#x2026;" == DA_HTML_ESCAPE.escape("…")
  end

  it "should encode mixed non-ASCII/ASCII text to hexadecimal" do
    assert(
      "&#x22;bient&#xf4;t&#x22; &#x26; &#x6587;&#x5b57;" == DA_HTML_ESCAPE.escape("\"bientôt\" & 文字")
    )
  end

  it "should not encode normal ASCII" do
    assert "%" == DA_HTML_ESCAPE.escape("%")
    assert "*" == DA_HTML_ESCAPE.escape("*")
    assert "y" == DA_HTML_ESCAPE.escape("y")
    assert " " == DA_HTML_ESCAPE.escape(" ")
  end

  it "should double encode existing entity" do
    assert "&#x26;amp;" == DA_HTML_ESCAPE.escape("&amp;")
  end

  it "should not mutate string being encoded" do
    original = "<£"
    input = original.dup
    DA_HTML_ESCAPE.escape(input)
    assert original == "<£"
  end

  it "should not replace newline \\n" do
    assert "\n\n\n" == DA_HTML_ESCAPE.escape("\n\n\n")
  end # === it "should not replace newline \\n"

  it "should replace control characters with spaces" do
    assert "a    " == DA_HTML_ESCAPE.escape("a\r\t\r")
  end # === it "should replace control characters with spaces"

  it "should encode from test set" do
    {% for x in TEST_ENTITIES_SET %}
      code    = {{x[1]}}
      decoded = {{x.last}}
      assert "&#x#{code.to_s(16)};" == DA_HTML_ESCAPE.escape(decoded)
    {% end %}
  end

end # === desc ":escape"

describe ":escape string encodings" do

  it "should encode ascii to ascii" do
    s = "<elan>"
    assert "&#x3c;elan&#x3e;" == DA_HTML_ESCAPE.escape(s)
  end

  it "should encode utf8 to utf8 if needed" do
    s =  "<élan>"
    assert "&#x3c;&#xe9;lan&#x3e;" == DA_HTML_ESCAPE.escape(s)
    actual = DA_HTML_ESCAPE.escape(s)
    assert( actual != nil)
  end

  it "should encode ascii to ascii" do
    assert "&#x3c;elan&#x3e;" == DA_HTML_ESCAPE.escape("<elan>")
  end

  it "should raise an error if invalid encoding" do
    slice = Bytes.new(2, 0_u8)
    slice[0]  = 255_u8
    slice[1]  = 65_u8
    s = String.new(slice)

    assert_raises(DA_HTML_ESCAPE::Error) {
      DA_HTML_ESCAPE.escape(s)
    }
  end

end # === desc ":escape string encodings"

describe ":escape" do # === Imported from Mu_Clean

  escape_tag_chars = "& < > \" ' /"

  it "escapes the tag related chars: #{escape_tag_chars}" do
    target = "&#x26; &#x3c; &#x3e; &#x22; &#x27; /"
    assert DA_HTML_ESCAPE.escape(escape_tag_chars) == target
  end # === it "escapes the following characters: "

  it "re-escapes already escaped text mixed with HTML" do
    html = "<p>Hi</p>";
    escaped = "&#x26;#x3c;p&#x26;#x3e;Hi&#x26;#x3c;/p&#x26;#x3e;"
    assert DA_HTML_ESCAPE.escape(DA_HTML_ESCAPE.escape(html) || "") == escaped
  end

  it "escapes special chars: \"Hello ©®∆\"" do
    s = "Hello & World ©®∆"
    t = "Hello &#x26; World &#xa9;&#xae;&#x2206;"
    assert DA_HTML_ESCAPE.escape(s) == t
  end

  it "escapes Unicode '<'" do
    actual = (DA_HTML_ESCAPE.escape("< \x3c \x3C \u003c \u003C") || "").split.uniq.join(" ")
    assert actual == "&#x3c;"
  end

end # === end desc

describe "Custom container: IO::Memory.new" do
  it "returns the original container" do
    t = IO::Memory.new
    actual = DA_HTML_ESCAPE.escape("<abc>", t)
    assert actual == t
  end # === it "returns the original container"

  it "adds the content to the container" do
    t = IO::Memory.new
    actual = DA_HTML_ESCAPE.escape("<abc>", t).to_s
    assert actual == "&#x3c;abc&#x3e;"
  end # === it "adds the content to the container"
end # === desc "Custom container: IO::Memory.new"


