require "./setup"
require "singleton"

class ParticleLife < Stylet2::Base
  class Cell
    delegate :renderer, :frame_counter, :window_rect, to: "ParticleLife.instance"

    def initialize
      @pos = vec2
    end

    def update
    end

    def render
      # renderer.draw_color = [0, 0, 255]
      # renderer.fill_rect(SDL2::Rect.new(*@pos, 32, 32))

      r = 64
      w, h = *window_rect
      x = w / 2 + Math.cos(Math::PI * frame_counter * 0.02 * 0.7) * w * 0.4
      y = h / 2 + Math.sin(Math::PI * frame_counter * 0.02 * 0.8) * h * 0.4
      renderer.fill_rect(SDL2::Rect.new(x - r, y - r, r * 2, r * 2))

    end
  end

  include Singleton

  CELL_N = 10

  def setup
    super

    @cells = CELL_N.times.collect { Cell.new }
  end

  def view
    super

    mouse_state = SDL2::Mouse.state
    mouse_pos = vec2(mouse_state.x, mouse_state.y)
    vputs mouse_pos
    renderer.draw_line(*(window_rect / 2), *mouse_pos)

    @cells.each do |e|
      e.render
    end
  end

  instance.run
end
