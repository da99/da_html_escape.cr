
module DA_HTML

  REGEX_UNSAFE_CHARS = /[^\ -~\n]+|[<>'"&]+/

  CHAR_HEX = {
    60 => "<".codepoints.first.to_s(16),
    62 => ">".codepoints.first.to_s(16),
    39 => "'".codepoints.first.to_s(16),
    34 => "\"".codepoints.first.to_s(16),
    38 => "&".codepoints.first.to_s(16)
  }

  def escape(source : String)
    return nil unless source.valid_encoding?
    clean(source)
      .gsub(REGEX_UNSAFE_CHARS){ |match|
      # space == \u{20}=(space) , ~ == \u{7E}
        match.codepoints.map { |x|
          "&#x#{CHAR_HEX[x]? || x.to_s(16)};"
        }.join
      }
  end

end # === module DA_HTML

