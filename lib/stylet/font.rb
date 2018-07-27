if $0 == __FILE__
  require_relative "../stylet"
end

module Stylet
  class FontList
    include ApplicationMemoryRecord
    memory_record Stylet.config.font_list

    delegate :line_skip, :text_size, :drawBlendedUTF8, :to => :sdl_ttf

    def initialize(*)
      super
      init
    end

    def init
      @_sdl_ttf = nil
      @char_width = nil
    end

    def char_width
      @char_width ||= sdl_ttf.text_size("A").first
    end

    def close
      if @_sdl_ttf
        @_sdl_ttf.close
        init
      end
    end

    concerning :BoldMethods do
      def bold
        (sdl_ttf.style & SDL::TTF::STYLE_BOLD).nonzero?
      end

      def bold=(v)
        if v
          sdl_ttf.style |= SDL::TTF::STYLE_BOLD
        else
          sdl_ttf.style &= ~SDL::TTF::STYLE_BOLD
        end
      end

      def bold_block(v)
        return yield if v.nil?

        bold_save = bold
        self.bold = v
        yield
        self.bold = bold_save
      end
    end

    private

    def sdl_ttf
      unless @_sdl_ttf
        if font_file = font_dir_list.collect {|e| Pathname(e) }.find {|e| e.exist? }
          @_sdl_ttf = SDL::TTF.open(font_file.to_s, @attributes[:font_size])
          Stylet.logger.debug "load: #{font_file} (#{@_sdl_ttf.family_name.inspect} #{@_sdl_ttf.style_name.inspect} #{@_sdl_ttf.height} #{@_sdl_ttf.line_skip} #{@_sdl_ttf.fixed_width?})" if Stylet.logger
          if @attributes[:bold]
            @_sdl_ttf.style |= SDL::TTF::STYLE_BOLD
          end
        end
      end
      @_sdl_ttf
    end

    def font_dir_list
      [
        @attributes[:path],
        "#{__dir__}/../../assets/fonts/#{@attributes[:path]}",
        "/Library/Fonts/Tahoma.ttf", # fallback font
      ]
    end
  end

  module Font
    attr_reader :system_font
    attr_reader :console_current_line

    def run_initializers
      super
      init_on(:font) do
        SDL::TTF.init
        @system_font = FontList[Stylet.config.system_font_key]
        @console_current_line = nil
      end
    end

    def before_draw
      super if defined? super
      @console_current_line = 0
    end

    def after_run
      super if defined? super
      FontList.each(&:close)
    end

    def update
      super
      if Stylet.config.production_keys.any? {|key| key_down?(key) }
        Stylet.production = !Stylet.production
      end
    end

    def dputs(*args)
      return if Stylet.production
      vputs(*args)
    end

    #
    # 文字列表示
    #
    #   vputs "Hello"                                             # 垂れ流し
    #   vputs "Hello", :vector => Vector[x, y]                    # 座標指定
    #   vputs "Hello", :vector => Vector[x, y], :align => :right  # 座標指定(右寄せ)
    #   vputs "Hello", :vector => Vector[x, y], :align => :center # 座標指定(中央)
    #
    def vputs(str = "", vector: nil, color: :font, align: :left, font: @system_font, bold: nil)
      str = str.to_s
      font = FontList[font]
      if vector
        begin
          x = vector.x
          if [:center, :right].include?(align)
            w = font.text_size(str).first
            case align
            when :right
              x -= w
            when :center
              x -= w / 2
            when :left
            else
              raise ArgumentError, align.inspect
            end
          end
          font.bold_block(bold) do
            font.drawBlendedUTF8(@screen, str, x, vector.y, *Palette.fetch(color))
          end
        rescue RangeError
        end
      else
        if v = vputs_vector
          vputs(str, vector: v, color: color, align: align, font: font, bold: bold)
          @console_current_line += font.line_skip
        end
      end
    end

    def vputs_vector
      if @console_current_line && @system_font
        vec2[0, @console_current_line]
      end
    end
  end
end

if $0 == __FILE__
  # require_relative "../stylet"
  # Stylet.config.font_name = "VeraMono.ttf"
  # Stylet.config.font_size = 20
  Stylet.run do
    vputs [*"A".."Z"].join
    vputs "left",   :vector => srect.center + [0, 20*0], :align => :left
    vputs "center", :vector => srect.center + [0, 20*1], :align => :center
    vputs "right",  :vector => srect.center + [0, 20*2], :align => :right
  end
end
