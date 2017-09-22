
require "myhtml"

module DA_HTML

  def unescape(source)
    return nil unless source.valid_encoding?
    Myhtml.decode_html_entities(clean(source))
  end

end # === module DA_HTML


