
module DA_HTML_ESCAPE

  class Error < Exception
  end

  TAB          = "\t"
  DOUBLE_SPACE = "  "
  NEW_LINE     = "\n"
  SPACE        = " "

  # # space == \u{20}=(space) , ~ == \u{7E}
  SPACE_CODEPOINT    = ' '.ord
  TILDA_CODEPOINT    = '~'.ord
  NEW_LINE_CODEPOINT = '\n'.ord
  TAB_CODEPOINT      = '\t'.ord

  REGEX_UNSAFE_CHARS      = /[^\ -~\n]+|[<>'"&]+/

  MACRO_UNSAFE_CHARS = [] of String

  macro unsafe_char(name, char)
    {{name.id}} = {{char}}.ord
    {{name.id}}_HEX = to_hex_entity({{char}})
    {{ MACRO_UNSAFE_CHARS << name }}
  end # === macro unsafe_char

  unsafe_char("LESS_THAN", '<')
  unsafe_char("MORE_THAN", '>')
  unsafe_char("AMPERSAND", '&')
  unsafe_char("SINGLE_QUOTE",'\'')
  unsafe_char("DOUBLE_QUOTE", '"')
  unsafe_char("BACKTICK", '`')
  unsafe_char("BRACKET_OPEN", '{')
  unsafe_char("BRACKET_CLOSE", '}')

  CNTRL_CHAR_REGEX = /[^\P{C}\n]+/

  def self.clean(s)
    s.gsub(TAB, DOUBLE_SPACE).gsub(CNTRL_CHAR_REGEX, SPACE)
  end # === def clean

  def self.to_hex_entity(x : Char)
    to_hex_entity(x.ord)
  end # === def self.to_hex_entity

  def self.to_hex_entity(x : Int32)
    "&\#x#{x.to_s(16)};"
  end # === def self.to_hex_entity

  def self.to_int32(s)
    s.codepoints.first
  end # === macro to_int32

  def self.escape(source : String)
    raise Error.new("Invalid encoding.") if !source.valid_encoding?

    new_str = IO::Memory.new
    source.codepoints.each { |x|

      new_str.<<(
        {% begin %}
          case x
            {% for x in MACRO_UNSAFE_CHARS %}
            when {{x.id}}
              {{x.id}}_HEX
            {% end %}
          when 9 # 9 = horizontal tab
            DOUBLE_SPACE
          when 10 # 10 = new line
            NEW_LINE
          when 0..31, 127 # Control character
            SPACE
          when SPACE_CODEPOINT..TILDA_CODEPOINT
            x.chr
          else
            to_hex_entity(x)
          end
      {% end %}
      )

    }
    new_str.to_s
  end

end # === module DA_HTML_ESCAPE


