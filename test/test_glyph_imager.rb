require 'helper'

class TestGlyphImager < Test::Unit::TestCase
  
  def setup
    @font_path = File.join(File.dirname(__FILE__), 'fonts', 'DejaVuSerif.ttf')
    @font = GlyphImager::FontRecord.new(@font_path)
    @output_dir = "/tmp"
  end
  
  def teardown
    if File.exists?("/tmp/0021-80x80.png")
      File.delete("/tmp/0021-80x80.png")
    end
    if File.exists?("/tmp/0027-80x80.png")
      File.delete("/tmp/0027-80x80.png")
    end
  end
  
  should "read font" do
    assert_not_nil @font
  end
  
  should "return font metadata" do
    assert_equal "DejaVu Serif", @font.full_font_name
    assert_equal "Copyright (c) 2003 by Bitstream, Inc. All Rights Reserved.\nDejaVu changes are in public domain\n", @font.copyright_notice
    assert_equal "DejaVu fonts team", @font.manufacturer_name
  end
  
  should "return true when glyph exists for character" do
    assert @font.has_glyph_for_unicode_char?("0021")
  end
  
  should "return false when glyph doesn't exist for character" do
    assert !@font.has_glyph_for_unicode_char?("11B14")
  end
  
  should "create new image" do
    @imager = GlyphImager::Imager.new({ 
      :code_point => "0021",
      :font_path => @font_path,
      :output_dir => "/tmp"
    })
    @imager.create_image
    assert File.exists?("/tmp/0021-80x80.png")
  end
  
  should "create new image for character supported by font" do
    GlyphImager.image_character_for_font({
      :code_point => "0021",
      :font_path => @font_path,
      :output_dir => "/tmp"
    })
    assert File.exists?("/tmp/0021-80x80.png")
  end
  
  should "create new image for 0027 (apostrophe)" do
    GlyphImager.image_character_for_font({
      :code_point => "0027",
      :font_path => @font_path,
      :output_dir => "/tmp"
    })
    assert File.exists?("/tmp/0021-80x80.png")
  end
  
  should "not create new image for character not supported by font" do
    GlyphImager.image_character_for_font({
      :code_point => "11B14",
      :font_path => @font_path,
      :output_dir => "/tmp"
    })
    assert !File.exists?("/tmp/11B14-80x80.png")
  end
  
end
