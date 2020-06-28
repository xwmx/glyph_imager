require 'helper'

describe GlyphImager do
  before do
    @fonts_dir = File.join(File.dirname(__FILE__), 'fonts')
    @font_path = File.join(@fonts_dir, 'DejaVuSerif.ttf')
    @font = GlyphImager::FontRecord.new(@font_path)
    @musica = GlyphImager::FontRecord.new(File.join(@fonts_dir, 'Musica.ttf'))

    @output_dir = '/tmp'
  end

  after do
    %w[0021 0027 005C].each do |code|
      if File.exist?("/tmp/#{code}-80x80.png")
        File.delete("/tmp/#{code}-80x80.png")
      end
    end
  end

  it 'should read font' do
    assert @font
  end

  it 'should return font metadata' do
    assert_equal 'DejaVu Serif', @font.font_name
    assert_equal "Copyright (c) 2003 by Bitstream, Inc. All Rights Reserved.\nDejaVu changes are in public domain\n", @font.copyright
    assert_equal 'DejaVu fonts team', @font.manufacturer
  end

  it 'should return true when glyph exists for character' do
    assert @font.has_glyph_for_unicode_char?('0021')
  end

  it 'should return true when glyph exists for high cp' do
    assert @musica.has_glyph_for_unicode_char?('1D032')
  end

  it 'should return false when glyph is control char' do
    assert !@font.has_glyph_for_unicode_char?('0000')
    assert !@font.has_glyph_for_unicode_char?('009F')
  end

  it "should return false when glyph doesn't exist for character" do
    assert !@font.has_glyph_for_unicode_char?('11B14')
  end

  it 'should create new image' do
    @imager = GlyphImager::Imager.new({
      :code_point => '0021',
      :font_path => @font_path,
      :output_dir => '/tmp'
    })
    @imager.create_image
    assert File.exist?('/tmp/0021-80x80.png')
  end

  it 'should create new image for character supported by font' do
    GlyphImager.image_character_for_font({
      :code_point => '0021',
      :font_path => @font_path,
      :output_dir => '/tmp'
    })
    assert File.exist?('/tmp/0021-80x80.png')
  end

  it 'should create new image for 0027 (apostrophe)' do
    GlyphImager.image_character_for_font({
      :code_point => '0027',
      :font_path => @font_path,
      :output_dir => '/tmp'
    })
    assert File.exist?('/tmp/0027-80x80.png')
  end

  it 'should create new image for 005C (reverse solidus aka backslash)' do
    GlyphImager.image_character_for_font({
      :code_point => '005C',
      :font_path => @font_path,
      :output_dir => '/tmp'
    })
    assert File.exist?('/tmp/005C-80x80.png')
  end

  it 'should not create new image for character not supported by font' do
    GlyphImager.image_character_for_font({
      :code_point => '11B14',
      :font_path => @font_path,
      :output_dir => '/tmp'
    })
    assert !File.exist?('/tmp/11B14-80x80.png')
  end

  it 'should generate command string with default background' do
    @imager = GlyphImager::Imager.new({
      :code_point => '0021',
      :font_path => @font_path,
      :output_dir => @output_dir
    })
    assert_match '-background none', @imager.command_string
  end

  it 'should generate command string with background from param' do
    @imager = GlyphImager::Imager.new({
      :code_point => '0021',
      :font_path => @font_path,
      :output_dir => @output_dir,
      :background => 'white'
    })
    assert_match '-background white', @imager.command_string
  end
end
