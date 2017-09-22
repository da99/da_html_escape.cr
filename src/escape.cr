
module DA_HTML

  macro to_hex_entity(str)
    "&#x#{{{str}}.codepoints.map { |x| x.to_s(16) }.join};"
  end # === macro to_hex_entity

  macro to_int32(s)
    {{s}}.codepoints.first
  end # === macro to_int32

  REGEX_UNSAFE_CHARS = /[^\ -~\n]+|[<>'"&]+/

  CHAR_HEX = {
    to_int32("<")  => to_hex_entity("<"),
    to_int32(">")  => to_hex_entity(">"),
    to_int32("'")  => to_hex_entity("'"),
    to_int32("\"") => to_hex_entity("\""),
    to_int32("&")  => to_hex_entity("&")
  }

  def escape(source : String)
    return nil unless source.valid_encoding?
    clean(source)
      .gsub(REGEX_UNSAFE_CHARS){ |match|
      # space == \u{20}=(space) , ~ == \u{7E}
        match.codepoints.map { |x|
          CHAR_HEX[x]? || "&#x#{x.to_s(16)};"
        }.join
      }
  end

end # === module DA_HTML

