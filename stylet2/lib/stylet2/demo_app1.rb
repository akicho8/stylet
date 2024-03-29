module Stylet2
  class DemoApp1 < Base
    def setup
      super

      self.background_blend_mode = SDL2::BlendMode::BLEND
      self.background_color = [0, 0, 64, 28]
    end

    def view
      super

      renderer.draw_blend_mode = SDL2::BlendMode::NONE
      renderer.draw_color = [255, 255, 255]

      r = 64
      w, h = window.size
      x = w / 2 + cos(PI * frame_counter * 0.02 * 0.7) * w * 0.4
      y = h / 2 + sin(PI * frame_counter * 0.02 * 0.8) * h * 0.4
      renderer.fill_rect(SDL2::Rect.new(x - r, y - r, r * 2, r * 2))
    end
  end
end
