module TTFunk
  class Table
    class Cmap
      module Format12
        attr_reader :language
        attr_reader :code_map
        def [](code)
          @code_map[code] || 0
        end
        def supported?
          true
        end
        private
        def parse_cmap!
          # skip reserved USHORT
          io.read(2)
          # read length, language and nGroups
          length, @language, n_groups = read(12, "NNN")
          # read the groups into code_map
          cmap_data = io.read(12*n_groups)
          # ruby is too slow to loop trough the code_map in real time, so we need to
          # prepare data and to store this in a hash
          @code_map = {}
          n_groups.times{ |i|
            start_index = i*12
            start_char_code,end_char_code,start_glyph_id =
              cmap_data[start_index..(start_index+12)].unpack("NNN")
            (start_char_code..end_char_code).each { |ch|
              @code_map[ch] = (ch-start_char_code) + start_glyph_id
            }
          }
        end
      end
    end
  end
end

