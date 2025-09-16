# frozen_string_literal: true

require 'ttfunk'
require 'open-uri'
require 'tempfile'
require 'uri'

module GlyphImager
  def self.image_character_for_font(options = {})
    [:code_point, :font_path, :output_dir].each do |k|
      raise ArgumentError, "missing value for :#{k}" if options[k].nil?
    end

    font = FontRecord.new(options[:font_path])

    return unless font.includes_glyph_for_unicode_char?(options[:code_point])

    GlyphImager::Imager.new(options.merge(font_path: font.font_path)).create_image
  ensure
    font.cleanup if font.respond_to?(:cleanup)
  end

  class FontRecord
    attr_reader :font_path

    METADATA_IDS = %w[
      copyright
      font_family
      font_subfamily
      unique_subfamily
      font_name
      version
      trademark
      manufacturer
      designer
      description
      vendor_url
      designer_url
      license
      license_url
      preferred_family
      preferred_subfamily
      compatible_full
      sample_text
    ].freeze

    METADATA_IDS.each do |m|
      define_method(m) do
        font.name.send(m).first
      end
    end

    def initialize(path_or_url)
      @cleanup_needed = false
      case
      when http_url?(path_or_url)
        @tmpfile = Tempfile.new(['font', File.extname(path_or_url)])
        @tmpfile.binmode
        @tmpfile.write URI.open(path_or_url).read
        @tmpfile.flush
        @font_path = @tmpfile.path
        @cleanup_needed = true
      when file_url?(path_or_url)
        @font_path = file_url_to_path(path_or_url)
      else
        @font_path = path_or_url
      end
      @font = TTFunk::File.open(@font_path)
    end

    def cleanup
      @tmpfile&.close!
    end

    def font
      @font
    end

    def includes_glyph_for_unicode_char?(code_point)
      return false if control_character_points.include?(code_point)

      if format12 = font.cmap.unicode.detect { |t| t.format == 12 }
        format12[code_point.hex] != 0
      elsif format4 = font.cmap.unicode.detect { |t| t.format == 4 }
        format4[code_point.hex] != 0
      end
    end

    def control_character_points
      return @control_character_points if defined? @control_character_points

      @control_character_points = 0.upto(31).collect do |i|
        ('%04x' % i).upcase
      end

      @control_character_points << '007F'

      @control_character_points += 128.upto(159).collect do |i|
        ('%04x' % i).upcase
      end
    end

    private

    def http_url?(str)
      str =~ /\Ahttps?:\/\//
    end

    def file_url?(str)
      str =~ /\Afile:\/\//
    end

    def file_url_to_path(file_url)
      uri = URI.parse(file_url)
      # Handles both file:///absolute/path and file:/absolute/path
      uri.path
    end
  end

  class Imager
    def initialize(opts = {})
      @options = {
        size: '80x80',
        pointsize_percentage: 100,
        gravity: 'center',
        background: 'none'
      }.merge(opts)

      [:code_point, :font_path, :output_dir].each do |k|
        raise ArgumentError, "missing value for :#{k}" if @options[k].nil?
      end
    end

    def output_path
      File.join(
        @options[:output_dir],
        "#{@options[:code_point]}-#{@options[:size]}.png"
      )
    end

    def pointsize
      @options[:size].split('x').last.to_i * @options[:pointsize_percentage] / 100.0
    end

    # label
    #
    # Return a label string formatted for the `convert` command.
    def label
      case @options[:code_point]
      when '0027'
        # Escape unquoted apostrophe: https://graphemica.com/0027
        "label:\\#{[@options[:code_point].hex].pack('U*')}"
      when '005C'
        # Escape apostrophe: https://graphemica.com/0027
        "label:'\\#{[@options[:code_point].hex].pack('U*')}'"
      else
        # Single quote label
        "label:'#{[@options[:code_point].hex].pack('U*')}'"
      end
    end

    def command_string
      <<-HEREDOC
        convert                                 \\
          -font #{@options[:font_path]}         \\
          -background #{@options[:background]}  \\
          -size #{@options[:size]}              \\
          -gravity #{@options[:gravity]}        \\
          -pointsize #{pointsize}               \\
          #{label}                              \\
          #{output_path}
      HEREDOC
    end

    def create_image
      %x[#{command_string}]
      return self
    end
  end
end
