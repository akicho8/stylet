require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    SDL::Mouse.hide
    @cursor.display = false

    @x = 1.0
    @y = 1.0

    @a = 1.40
    @b = 1.56
    @c = 1.40
    @d = -6.56
  end

  update do
    10000.times do
      xn = @d * Math.sin(@a * @x) - Math.sin(@b * @y)
      yn = @c * Math.cos(@a * @x) + Math.cos(@b * @y)

      @x = xn
      @y = yn
      p0 = srect.center + [@x * srect.w * 0.06, @y * srect.h * 0.12]

      r, g, b = screen.get_rgb(screen[*p0])
      r = Stylet::Chore.max_clamp(r + 4*1, 255)
      g = Stylet::Chore.max_clamp(g + 4*3, 255)
      b = Stylet::Chore.max_clamp(b + 4*2, 255)
      screen[*p0] = screen.format.map_rgb(r, g, b)
    end
  end

  def background_clear
  end

  def system_infos
    []
  end

  run
end
