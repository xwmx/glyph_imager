require 'helper'

class TestGlyphImager < Test::Unit::TestCase
  
  def setup
    @font = GlyphImager::GlyphQuery.new(File.join(File.dirname(__FILE__), 'fonts', 'DejaVuSerif.ttf'))
  end
  
  should "read font" do
    assert_not_nil @font
  end
  
  should "return true when glyph exists for character" do
    assert @font.has_glyph_for_unicode_char?("0021")
  end
  
  should "return false when glyph doesn't exist for character" do
    assert !@font.has_glyph_for_unicode_char?("11B14")
  end
end
