
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
    DA_HTML.escape(input)

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
    assert_not_nil DA_HTML.escape(s) do |x|
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

    DA_HTML.escape(s).should eq(nil)
  end

end # === desc ":escape string encodings"

describe ":escape" do # === Imported from Mu_Clean

  escape_tag_chars = "& < > \" ' /"

  it "escapes the tag related chars: #{escape_tag_chars}" do
    target = "&amp; &lt; &gt; &quot; &#x27; &#x2F;"
    assert target , :==, Mu_Clean.escape_html(escape_tag_chars)
  end # === it "escapes the following characters: "

  it "does not re-escape already escaped text mixed with HTML" do
    html = "<p>Hi</p>";
    escaped = Mu_Clean.escape_html(html);
    assert Mu_Clean.escape_html(escaped + html), :==, Mu_Clean.escape_html(html + html)
  end

  it "escapes special chars: \"Hello ©®∆\"" do
    s = "Hello & World ©®∆"
    t = "Hello &amp; World &#169;&#174;&#8710;"
    t = "Hello &amp; World &copy;&reg;&#x2206;"
    assert t, :==, Mu_Clean.escape_html(s)
  end

  it "escapes all 70 different combos of '<'" do
    assert "&lt; %3C", :==, Mu_Clean.escape_html(BRACKET).split.uniq.join(" ")
  end

  it "escapes all keys in nested objects" do
    html = "<b>test</b>"
    t    = {" a &gt;" => {" a &gt;" => Mu_Clean.escape_html(html) }}
    assert t, :==, Mu_Clean.escape_html({" a >" => {" a >" => html}})
  end

  it "escapes all values in nested objects" do
    html = "<b>test</b>"
    t    = {name: {name: Mu_Clean.escape_html(html)}}
    assert t, :==, Mu_Clean.escape_html({name:{name: html}})
  end

  it "escapes all values in nested arrays" do
    html = "<b>test</b>"
    assert [{name: {name: Mu_Clean.escape_html(html)}}], :==, Mu_Clean.escape_html([{name:{name: html}}])
  end

  "uri url href".split.each { |k| # ==============================================

    it "escapes values of keys :#{k} that are valid /path" do
      a = {:key=>{:"#{k}" => "/path/mine/&"}}
      t = {:key=>{:"#{k}" => "/path/mine/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "sets nil any keys ending with :#{k} and have invalid uri" do
      a = {:key=>{"#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"#{k}" => nil                  }}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "sets nil any keys ending with _#{k} and have invalid uri" do
      a = {:key=>{"my_#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"my_#{k}" => nil                  }}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys with _#{k} that are valid https uri" do
      a = {:key=>{"my_#{k}" => "https://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "https://www.yahoo.com/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys with _#{k} that are valid uri" do
      a = {:key=>{"my_#{k}" => "http://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "http://www.yahoo.com/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys ending with _#{k} that are valid /path" do
      a = {:key=>{"my_#{k}" => "/path/mine/&"}}
      t = {:key=>{"my_#{k}" => "/path/mine/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "allows unicode uris" do
      a = {:key=>{"my_#{k}" => "http://кц.рф"}}
      t = {:key=>{"my_#{k}" => "http://&#x43a;&#x446;.&#x440;&#x444;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end
  }

  [true, false].each do |v|
    it "does not escape #{v.inspect}" do
      a = {"something"=>v}
      assert a, :==, Mu_Clean.escape_html(a)
    end
  end

  it "does not escape numbers" do
    a = {"something"=>1.to_i64}
    assert a, :==, Mu_Clean.escape_html(a)
  end

end # === end desc

