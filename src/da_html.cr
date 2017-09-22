
module DA_HTML

  extend self

  def clean(s)
    s.gsub("\t", "  ").gsub(/[^\P{C}\n]+/, " ")
  end # === def clean

end # === class DA_HTML

require "./unescape"
require "./escape"


