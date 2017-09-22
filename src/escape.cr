
module DA_HTML

  def escape(source : String)
    return nil unless source.valid_encoding?
    clean(source)
      .gsub(/[^\ -~\n]+|[<>'"&]+/){ |match|
      # space == \u{20}=(space) , ~ == \u{7E}
        match.codepoints.map { |x|
          "&#x#{x.to_s(16)};"
        }.join
      }
  end

end # === module DA_HTML

