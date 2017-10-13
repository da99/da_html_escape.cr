
describe ":escape" do

  it "should replace \"unit separator\" (31 ASCII) with a space" do
    assert_escape "a ", "a\u{1f}"
  end

  it "should encode apos entity" do
    assert_escape "&#x27;", "'"
  end

  it "encodes README.md example" do
    assert_escape "&#x3c;&#xe9;lan&#x3e;", "<élan>"
  end

  it "should encode basic entities to hexadecimal" do
    assert_escape "&#x26;", "&"
    assert_escape "&#x22;", "\""
    assert_escape "&#x3c;", "<"
    assert_escape "&#x3e;", ">"
    assert_escape "&#x27;", "'"
    assert_escape "&#x2212;", "−"
    assert_escape "&#x2014;", "—"
  end

  it "should non-ASCII entities to hexadecimal" do
    assert_escape "&#xb1;",  "±"
    assert_escape "&#xf0;",  "ð"
    assert_escape "&#x152;", "Œ"
    assert_escape "&#x153;", "œ"
    assert_escape "&#x201c;", "“"
    assert_escape "&#x2026;", "…"
  end

  it "should mixed non-ASCII/ASCII text to hexadecimal" do
    assert_escape(
      "&#x22;bient&#xf4;t&#x22; &#x26; &#x6587;&#x5b57;",
      "\"bientôt\" & 文字"
    )
  end

  it "should sort commands when encoding using mix of entities" do
    assert_escape(
      "&#x22;bient&#xf4;t&#x22; &#x26; &#x6587;&#x5b57;",
      "\"bientôt\" & 文字"
    )
  end

  it "should not encode normal ASCII" do
    assert_escape "`", "`"
    assert_escape " ", " "
  end

  it "should double encode existing entity" do
    assert_escape "&#x26;amp;", "&amp;"
  end

  it "should not mutate string being encoded" do
    original = "<£"
    input = original.dup
    DA_HTML_ESCAPE.escape(input)

    original.should eq( input )
  end

  it "should not replace newline \\n" do
    assert_escape "\n\n\n", "\n\n\n"
  end # === it "should not replace newline \\n"

  it "should replace control characters with spaces" do
    assert_escape "a    ", "a\r\t\r"
  end # === it "should replace control characters with spaces"

  it "should encode from test set" do
    {% for x in TEST_ENTITIES_SET %}
      code    = {{x[1]}}
      decoded = {{x.last}}
      assert_escape "&#x#{code.to_s(16)};", decoded
    {% end %}
  end

end # === desc ":escape"

describe ":escape string encodings" do

  it "should encode ascii to ascii" do
    s = "<elan>"
    assert_escape "&#x3c;elan&#x3e;", s
  end

  it "should encode utf8 to utf8 if needed" do
    s =  "<élan>"
    assert_escape "&#x3c;&#xe9;lan&#x3e;", s
    assert_not_nil DA_HTML_ESCAPE.escape(s) do |x|
      x.valid_encoding?.should eq(true)
    end
  end

  it "should encode ascii to ascii" do
    assert_escape "&#x3c;elan&#x3e;", "<elan>"
  end

  it "should return nil if invalid encoding" do
    slice = Bytes.new(2, 0_u8)
    slice[0]  = 255_u8
    slice[1]  = 65_u8
    s = String.new(slice)

    DA_HTML_ESCAPE.escape(s).should eq(nil)
  end

end # === desc ":escape string encodings"

describe ":escape" do # === Imported from Mu_Clean

  escape_tag_chars = "& < > \" ' /"

  it "escapes the tag related chars: #{escape_tag_chars}" do
    target = "&amp; &lt; &gt; &quot; &#x27; &#x2F;"
    DA_HTML_ESCAPE.escape(escape_tag_chars)
      .should eq(target)
  end # === it "escapes the following characters: "

  it "does not re-escape already escaped text mixed with HTML" do
    html = "<p>Hi</p>";
    escaped = DA_HTML_ESCAPE.escape(html) || ""
    DA_HTML_ESCAPE.escape(escaped + html)
      .should eq(DA_HTML_ESCAPE.escape(html + html))
  end

  it "escapes special chars: \"Hello ©®∆\"" do
    s = "Hello & World ©®∆"
    t = "Hello &amp; World &#169;&#174;&#8710;"
    t = "Hello &amp; World &copy;&reg;&#x2206;"
    DA_HTML_ESCAPE.escape(s)
      .should eq(t)
  end

  it "escapes all 70 different combos of '<'" do
    (DA_HTML_ESCAPE.escape(BRACKET) || "").split.uniq.join(" ")
      .should eq("&lt; %3C")
  end


end # === end desc

