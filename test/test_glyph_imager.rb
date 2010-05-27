require 'helper'

class TestGlyphImager < Test::Unit::TestCase
  
  def setup
    @fonts_dir = File.join(File.dirname(__FILE__), 'fonts')
    @font_path = File.join(@fonts_dir, 'DejaVuSerif.ttf')
    @font = GlyphImager::FontRecord.new(@font_path)
    @times = GlyphImager::FontRecord.new(File.join(@fonts_dir, 'other', 'TimesRoman.ttf'))
    @musica = GlyphImager::FontRecord.new(File.join(@fonts_dir, 'Musica.ttf'))
    
    @output_dir = "/tmp"
  end
  
  def teardown
    %w[0021 0027 005C].each do |code|
      if File.exists?("/tmp/#{code}-80x80.png")
        File.delete("/tmp/#{code}-80x80.png")
      end
    end
  end
  
  should "read font" do
    assert_not_nil @font
  end
  
  should "return font metadata" do
    assert_equal "DejaVu Serif", @font.font_name
    assert_equal "Copyright (c) 2003 by Bitstream, Inc. All Rights Reserved.\nDejaVu changes are in public domain\n", @font.copyright
    assert_equal "DejaVu fonts team", @font.manufacturer
  end
  
  should "return true when glyph exists for character" do
    assert @font.has_glyph_for_unicode_char?("0021")
  end
  
  should "return true when glyph exists for high cp" do
    assert @musica.has_glyph_for_unicode_char?("1D032")
  end
    
  should "return false when glyph is control char" do
    assert !@times.has_glyph_for_unicode_char?("0000")
    assert !@times.has_glyph_for_unicode_char?("009F")
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
    assert File.exists?("/tmp/0027-80x80.png")
  end
  
  should "create new image for 005C (reverse solidus aka backslash)" do
    GlyphImager.image_character_for_font({
      :code_point => "005C",
      :font_path => @font_path,
      :output_dir => "/tmp"
    })
    assert File.exists?("/tmp/005C-80x80.png")
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
