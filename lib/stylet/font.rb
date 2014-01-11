# -*- coding: utf-8 -*-
module Stylet
  module Font
    def sdl_initialize
      super if defined? super
      SDL::TTF.init
      if Stylet.config.font_name
        font_file = Pathname("#{__dir__}/assets/#{Stylet.config.font_name}")
        if font_file.exist?
          @font = SDL::TTF.open(font_file.to_s, Stylet.config.font_size)
          logger.debug "load: #{font_file}" if logger
          if Stylet.config.font_bold
            @font.style = SDL::TTF::STYLE_BOLD
          end
        end
      end
      p ["#{__FILE__}:#{__LINE__}", __method__]
    end

    def before_draw
      super if defined? super
      @__vputs_lines = 0
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
    # フォント表示
    #
    #   vputs "Hello"                               # 垂れ流し
    #   vputs "Hello", :vector => Vector.new(1, 2)  # 座標指定
    #
    def vputs(str, vector: nil, color: "font")
      return unless @font
      str = str.to_s
      return if str.empty?

      if vector
        begin
          @font.drawBlendedUTF8(@screen, str, vector.x, vector.y, *Palette[color])
        rescue RangeError
        end
      else
        vputs(str, :vector => Vector.new(0, @__vputs_lines * (@font.line_skip + Stylet.config.font_margin)), :color => color)
        @__vputs_lines += 1
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.config.font_name = "VeraMono.ttf"
  Stylet.config.font_size = 20
  Stylet.run do |win|
    25.times{|i|win.vputs [i, ("A".."Z").to_a.join].join(" ")}
  end
end
