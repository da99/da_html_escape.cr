
module DA_HTML_ESCAPE

  macro to_hex_entity(str)
    "&#x#{{{str}}.codepoints.map { |x| x.to_s(16) }.join};"
  end # === macro to_hex_entity

  macro to_int32(s)
    {{s}}.codepoints.first
  end # === macro to_int32

  # space == \u{20}=(space) , ~ == \u{7E}
  SPACE_CODEPOINT = to_int32(" ")
  TILDA_CODEPOINT = to_int32("~")
  NEW_LINE_CODEPOINT = to_int32("\n")
  TAB_CODEPOINT = to_int32("\t")

  UNSAFE_ASCII_CODEPOINTS = "<>&'\"`{}".codepoints
  ASCII_TABLE = Array(String | Nil).new("~".codepoints.first + 1, nil)

  (SPACE_CODEPOINT..TILDA_CODEPOINT).each do |x|
    next if UNSAFE_ASCII_CODEPOINTS.includes?(x)
    ASCII_TABLE[x] = [x.chr].join
  end

  ASCII_TABLE[NEW_LINE_CODEPOINT] = "\n"

  REGEX_UNSAFE_CHARS = /[^\ -~\n]+|[<>'"&]+/

  CHAR_HEX = {
    to_int32("<")  => to_hex_entity("<"),
    to_int32(">")  => to_hex_entity(">"),
    to_int32("'")  => to_hex_entity("'"),
    to_int32("\"") => to_hex_entity("\""),
    to_int32("&")  => to_hex_entity("&"),
    to_int32("`")  => to_hex_entity("`"),
    to_int32("{")  => to_hex_entity("{"),
    to_int32("}")  => to_hex_entity("}")
  }

  def escape(source : String)
    return nil unless source.valid_encoding?
    new_str = IO::Memory.new
    source.codepoints.each { |x|

      new_str.<<(
        case x
      when 9 # tab
        DOUBLE_SPACE
      when 10 # 10 = new line
        NEW_LINE
      when 0..31, 127 # Control character
        SPACE
      else
        (ASCII_TABLE[x]? && ASCII_TABLE[x]) || CHAR_HEX[x]? || "&#x#{x.to_s(16)};"
      end
      )

    }
    new_str.to_s
  end

end # === module DA_HTML_ESCAPE

