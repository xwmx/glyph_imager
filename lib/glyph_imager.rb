$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'vendor', 'ttf-ruby-0.1', 'lib'))
require 'ttf'

module GlyphImager
  class GlyphQuery
    
    def initialize(filename)
      @font = Font::TTF::File.new(filename)
    end
    
    def get_encoding_table4
      @enc_tbl ||= @font.get_table(:cmap).encoding_tables.find do |t|
          t.class == Font::TTF::Table::Cmap::EncodingTable4
      end
    end
    
    def has_glyph_for_unicode_char?(code_point)
      get_encoding_table4.get_glyph_id_for_unicode(code_point.hex) != 0
    end
    
  end
end