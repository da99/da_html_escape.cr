
require "myhtml"

module DA_HTML

  def unescape(source)
    return nil unless source.valid_encoding?
    Myhtml.decode_html_entities(clean(source))
  end

  def unescape!(source : String)
    str = unescape(source)
    return str if str == source
    unescape!(str)
  end # === def unescape

end # === module DA_HTML


