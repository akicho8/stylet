module Stylet2
  module WindowMethods
    attr_accessor :window
    attr_accessor :window_rect
    attr_accessor :renderer
    attr_accessor :frame_counter
    attr_accessor :background_blend_mode
    attr_accessor :background_color

    def setup
      super

      flags = 0
      if params[:full_screen]
        flags |= SDL2::Window::Flags::FULLSCREEN
        # flags |= SDL2::Window::Flags::FULLSCREEN_DESKTOP
      end
      pos = SDL2::Window::POS_CENTERED
      @window = SDL2::Window.create("(Title)", pos, pos, 640, 480, flags)
      @window_rect = Vector2d(*@window.size)

      flags = 0
      flags |= SDL2::Renderer::Flags::ACCELERATED
      flags |= SDL2::Renderer::Flags::PRESENTVSYNC
      @renderer = @window.create_renderer(-1, flags)

      @frame_counter = 0

      self.background_blend_mode = SDL2::BlendMode::NONE
      self.background_color = [0, 0, 64, 28]
    end

    def before_view
      super

      background_clear
      after_background_clear

      renderer.draw_blend_mode = SDL2::BlendMode::NONE
      renderer.draw_color = [255, 255, 255]
    end

    def after_process
      super

      @frame_counter += 1
      renderer.present
    end

    def background_clear
      if background_color
        renderer.draw_blend_mode = background_blend_mode
        renderer.draw_color = background_color
        renderer.fill_rect(SDL2::Rect.new(0, 0, *window_rect))
      end
    end

    def after_background_clear
    end

    # p0 から p1 へ矢印の描画
    def draw_arrow(p0, p1, options = {})
      d = p0 - p1

      # if d.x.nan? || d.y.nan?
      #   return
      # end

      # options = {
      #   :angle      => PI * 0.25,             # 傘の開き
      #   :arrow_size => p0.distance(p1) * 0.1, # 傘の大きさは線分の長さに比例
      # }.merge(options)

      renderer.draw_line(*p0, *p1)

      # # 傘の表示
      # a = p1.angle_to(p0)
      draw_line(p1, p1 + Vector.angle_at(a + options[:angle]).scale(options[:arrow_size]), options)
      draw_line(p1, p1 + Vector.angle_at(a - options[:angle]).scale(options[:arrow_size]), options)
    end

  end

  Base.prepend WindowMethods
end
