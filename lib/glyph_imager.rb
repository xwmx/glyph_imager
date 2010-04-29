$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'vendor', 'ttf-ruby-0.1', 'lib'))
require 'ttf'

module GlyphImager
  
  def self.image_character_for_font(options = {})
    %w[code_point font_path output_dir].each do |k|
      if options[k.to_sym].nil?
        raise ArgumentError, "missing value for :#{k}"
      end
    end
    font = FontRecord.new(options[:font_path])
    if font.has_glyph_for_unicode_char?(options[:code_point])
      imager = GlyphImager::Imager.new(options)
      imager.create_image
      return imager
    end
  end
  
  
  
  class FontRecord
    
    @@metadata_ids = %w[
      copyright_notice
      font_family_name
      font_subfamily_name
      unique_font_identifier
      full_font_name
      version_string
      postscript_name
      trademark
      manufacturer_name
      designer_name
      description
      vendor_url
      designer_url
      license_description
      license_url
      reserved
      preferred_family
      preferred_subfamily
      compatible_full
    ]
    
    
    @@metadata_ids.each do |m|
      define_method(m) do
        name_table.find_record_by_id(@@metadata_ids.index(m)).to_s
      end
    end
    
    def initialize(filename)
      @font = TTFFont::TTF::FontLoader.new(filename)
    end
    
    def font
      @font
    end
    
    def name_table
      @name_table ||= @font.get_table(:name)
    end
    
    def get_encoding_table4
      @enc_tbl ||= @font.get_table(:cmap).encoding_tables.find do |t|
          t.class == TTFFont::TTF::Table::Cmap::EncodingTable4
      end
    end
    
    def has_glyph_for_unicode_char?(code_point)
      get_encoding_table4.get_glyph_id_for_unicode(code_point.hex) != 0
    end
    
  end
  
  class Imager
    
    def initialize(opts = {})
      @options = { :size => "80x80" }.merge(opts)
      %w[code_point font_path output_dir].each do |k|
        if @options[k.to_sym].nil?
          raise ArgumentError, "missing value for :#{k}"
        end
      end
    end
    
    def output_path
      "#{@options[:output_dir]}/#{@options[:code_point]}-#{@options[:size]}.png"
    end
    
        
    def create_image
      %x[convert -font #{@options[:font_path]} -size #{@options[:size]} -gravity center label:#{["#{@options[:code_point]}".hex].pack("U*")} #{output_path}]
      return self
    end
    
  end
  
end