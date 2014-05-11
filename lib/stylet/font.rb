# -*- coding: utf-8 -*-
module Stylet
  module Font
    attr_reader :font
    attr_reader :font_width

    def run_initializers
      super
      init_on(:font) do
        SDL::TTF.init
        if Stylet.config.font_name
          font_file = Pathname("#{__dir__}/assets/#{Stylet.config.font_name}")
          if font_file.exist?
            @font = SDL::TTF.open(font_file.to_s, Stylet.config.font_size)
            logger.debug "load: #{font_file} (#{@font.family_name.inspect} #{@font.style_name.inspect} #{@font.height} #{@font.line_skip} #{@font.fixed_width?})" if logger
            if Stylet.config.font_bold
              @font.style = SDL::TTF::STYLE_BOLD
            end
            @font_width = @font.text_size("A").first
          end
        end
      end
    end

    def before_draw
      super if defined? super
      @_console_lines = 0
    end

    def after_run
      super if defined? super
      if @font
        @font.close
      end
    end

    def update                  # FIXME: update をつかわないようにする
      super
      if Stylet.config.production_keys.any?{|key|key_down?(key)}
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
    def vputs(str, vector: nil, color: :font, align: :left)
      return unless @font
      str = str.to_s
      return if str.empty?

      if vector
        begin
          x = vector.x
          if [:center, :right].include?(align)
            w = @font.text_size(str).first
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
          @font.drawBlendedUTF8(@screen, str, x, vector.y, *Palette.fetch(color))
        rescue RangeError
        end
      else
        if @_console_lines
          vputs(str, :vector => vec2[0, @_console_lines * @font.line_skip], color: color, align: align)
          @_console_lines += 1
        end
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.config.font_name = "VeraMono.ttf"
  Stylet.config.font_size = 20
  Stylet.run do
    vputs ("A".."Z").to_a.join
    vputs "left",   :vector => rect.center + [0, 20*0], :align => :left
    vputs "center", :vector => rect.center + [0, 20*1], :align => :center
    vputs "right",  :vector => rect.center + [0, 20*2], :align => :right
  end
end
