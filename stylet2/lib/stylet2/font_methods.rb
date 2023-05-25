module Stylet2
  module FontMethods
    attr_accessor :font
    attr_accessor :vputs_pos

    def setup
      super

      font_file = Pathname("~/Library/Fonts/Ricty-Regular.ttf").expand_path.to_s

      SDL2::TTF.init
      @font = SDL2::TTF.open(font_file, params[:font_size])
      @font.kerning = true

      vputs_pos_reset
    end

    def after_view
      system_infos_draw
      vputs_pos_reset

      super
    end

    def system_infos_draw
      if v = system_infos
        unless v.empty?
          vputs2 v.join(" ")
        end
      end
    end

    def vputs(text)
      vputs2 text, position: @vputs_pos
      @vputs_pos += vec2(0, 1)
    end

    def vputs2(text, options = {})
      options = {
        background: false,
      }.merge(options)

      text = text.to_s

      position = options[:position] || vec2(0, 0)
      position *= vec2(1, font.line_skip)
      rect = SDL2::Rect.new(*position, *font.size_text(text))

      if options[:background]
        renderer.draw_blend_mode = SDL2::BlendMode::NONE
        renderer.draw_color = [0, 0, 128]
        renderer.fill_rect(rect)
      end

      font_color = [255, 255, 255]
      texture = renderer.create_texture_from(font.render_blended(text, font_color))
      renderer.copy(texture, nil, rect)
    end

    def vputs_pos_reset
      @vputs_pos = vec2(0, 1)
    end

    def system_infos
      [frame_counter, "#{fps}fps"]
    end
  end

  Base.prepend FontMethods
end
