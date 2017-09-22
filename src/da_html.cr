
module DA_HTML

  extend self

  TAB          = "\t"
  DOUBLE_SPACE = "  "
  NEW_LINE     = "\n"
  SPACE        = " "

  CLEAN_CNTRL = {
    "\t" => "  ",
    "\n" => "\n"
  }

  CNTRL_CHAR_REGEX = /[^\P{C}\n]+/

  def clean(s)
    s.gsub(TAB, DOUBLE_SPACE).gsub(CNTRL_CHAR_REGEX, SPACE)
  end # === def clean

end # === class DA_HTML

require "./unescape"
require "./escape"


