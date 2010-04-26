require 'helper'

class TestGlyphImager < Test::Unit::TestCase
  
  def setup
    @font_path = File.join(File.dirname(__FILE__), 'fonts', 'DejaVuSerif.ttf')
    @font = GlyphImager::GlyphQuery.new(@font_path)
    @output_dir = "/tmp"
  end
  
  def teardown
    if File.exists?("/tmp/0021.png")
      File.delete("/tmp/0021.png")
    end
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
  
  should "convert create new image" do
    @imager = GlyphImager::Imager.new({ 
      :code_point => "0021",
      :font_path => @font_path,
      :output_dir => "/tmp" })
    @imager.create_image
    assert File.exists?("/tmp/0021.png")
  end
  
  
end
