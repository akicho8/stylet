require "./setup"

class TixyCloneApp < Stylet2::Base
  CELL_N = 16

  def setup
    super

    @cell_wh        = window_rect * 1.0 / CELL_N
    @inner_top_left = window_rect * 0.5 - @cell_wh * CELL_N * 0.5
  end

  def before_view
    renderer.draw_color = [0, 0, 0]
    renderer.clear
  end

  def view
    super

    time = SDL2.get_ticks.fdiv(1000)
    index = 0
    CELL_N.times do |y|
      CELL_N.times do |x|
        r = tixy_func(time, index, x, y)
        if r.nonzero?
          r = r.clamp(-1.0, 1.0)
          center = @inner_top_left + @cell_wh * Vector2d(x, y) + @cell_wh * 0.5
          radius = @cell_wh * 0.5 * r.abs * 0.95
          top_left = center - radius
          renderer.draw_color = tixy_color(r)
          renderer.fill_rect(SDL2::Rect.new(*top_left, *(radius * 2)))
        end
        index += 1
      end
    end
  end

  def tixy_func(t, i, x, y)
    sin(t - sqrt((x - 7.5)**2 + (y - 6)**2))
  end

  def tixy_color(v)
    if v.positive?
      v = 1.0
    else
      v = -1.0
    end
    c = v.abs * 255
    if v.positive?
      [c, c, c]
    else
      [c, 0, 0]
    end
  end

  run
end
