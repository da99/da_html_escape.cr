
require "../src/da_html"

class The_Job

  @encoded : String

  def initialize
    @coder   = DA_HTML
    @decoded = File.read("#{__DIR__}/sample")
    encoded  = @coder.escape(@decoded)
    if encoded
      @encoded = encoded
    else
      raise Exception.new("Sample has invalid codepoints.")
    end
  end

  def escape(cycles)
    cycles.times do
      @coder.escape(@decoded)
    end
  end

  def unescape!(cycles)
    cycles.times do
      @coder.unescape!(@encoded)
    end
  end

  def unescape_once(cycles)
    cycles.times do
      @coder.unescape_once(@encoded)
    end
  end # === def unescape_once

  def all(cycles)
    escape(cycles)
    unescape_once(cycles)
    unescape!(cycles)
  end

end # === The_Job

