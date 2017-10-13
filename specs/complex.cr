

  it "escapes all keys in nested objects" do
    html = "<b>test</b>"
    t    = {" a &gt;" => {" a &gt;" => DA_HTML_ESCAPE.escape(html) }}
    assert t, :==, DA_HTML_ESCAPE.escape({" a >" => {" a >" => html}})
  end

  it "escapes all values in nested objects" do
    html = "<b>test</b>"
    t    = {name: {name: DA_HTML_ESCAPE.escape(html)}}
    assert t, :==, DA_HTML_ESCAPE.escape({name:{name: html}})
  end

  it "escapes all values in nested arrays" do
    html = "<b>test</b>"
    assert [{name: {name: DA_HTML_ESCAPE.escape(html)}}], :==, DA_HTML_ESCAPE.escape([{name:{name: html}}])
  end

  "uri url href".split.each { |k| # ==============================================

    it "escapes values of keys :#{k} that are valid /path" do
      a = {:key=>{:"#{k}" => "/path/mine/&"}}
      t = {:key=>{:"#{k}" => "/path/mine/&amp;"}}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "sets nil any keys ending with :#{k} and have invalid uri" do
      a = {:key=>{"#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"#{k}" => nil                  }}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "sets nil any keys ending with _#{k} and have invalid uri" do
      a = {:key=>{"my_#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"my_#{k}" => nil                  }}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "escapes values of keys with _#{k} that are valid https uri" do
      a = {:key=>{"my_#{k}" => "https://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "https://www.yahoo.com/&amp;"}}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "escapes values of keys with _#{k} that are valid uri" do
      a = {:key=>{"my_#{k}" => "http://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "http://www.yahoo.com/&amp;"}}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "escapes values of keys ending with _#{k} that are valid /path" do
      a = {:key=>{"my_#{k}" => "/path/mine/&"}}
      t = {:key=>{"my_#{k}" => "/path/mine/&amp;"}}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end

    it "allows unicode uris" do
      a = {:key=>{"my_#{k}" => "http://кц.рф"}}
      t = {:key=>{"my_#{k}" => "http://&#x43a;&#x446;.&#x440;&#x444;"}}
      assert t, :==, DA_HTML_ESCAPE.escape(a)
    end
  }

  [true, false].each do |v|
    it "does not escape #{v.inspect}" do
      a = {"something"=>v}
      assert a, :==, DA_HTML_ESCAPE.escape(a)
    end
  end

  it "does not escape numbers" do
    a = {"something"=>1.to_i64}
    assert a, :==, DA_HTML_ESCAPE.escape(a)
  end
