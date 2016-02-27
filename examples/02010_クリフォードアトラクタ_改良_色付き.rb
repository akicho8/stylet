require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    SDL::Mouse.hide
    @cursor.display = false

    @x = 1.0
    @y = 1.0

    reset
  end

  update do
    if frame_counter.modulo(30).zero?
      _background_clear
    end

    @b += (button.btA.repeat - button.btB.repeat) * 0.1

    10000.times do
      xn = Math.sin(@a * @y) - @c * Math.cos(@a * @x)
      yn = Math.sin(@b * @x) - @d * Math.cos(@b * @y)
      @x = xn
      @y = yn
      p0 = srect.center + [@x * srect.w * 0.3, @y * srect.h * 0.3]

      r, g, b = screen.get_rgb(screen[*p0])
      r = Stylet::Etc.max_clamp(r + 4*1, 255)
      g = Stylet::Etc.max_clamp(g + 4*3, 255)
      b = Stylet::Etc.max_clamp(b + 4*2, 255)
      screen[*p0] = screen.format.map_rgb(r, g, b)
    end
  end

  def background_clear
  end

  def system_infos
    []
  end

  def reset
    @a = 1.88
    @b = -1.7
    @c = -0.43
    @d = -0.74
  end

  run
end
