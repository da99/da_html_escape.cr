
require "../src/da_html"

class The_Job

  @encoded : String
  def initialize
    @coder = DA_HTML
    @raw = File.read("#{__DIR__}/sample")
    @decoded = @raw
    encoded = @coder.escape(@decoded)
    if encoded
      @encoded = encoded
    else
      raise Exception.new("Sample has invalid codepoints.")
    end
  end

  def escape(cycles)
    cycles.times do
      @coder.escape(@raw)
      @coder.escape(@decoded)
    end
  end

  def unescape(cycles)
    cycles.times do
      @coder.unescape!(@encoded)
    end
  end

  def all(cycles)
    escape(cycles)
    unescape(cycles)
  end

end # === The_Job

