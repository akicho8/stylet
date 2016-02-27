require_relative "helper"

class App < Stylet::Base
  setup do
    @x = 1
    @y = 1

    @a = 1.88
    @b = -1.7
    @c = -0.43
    @d = -0.74
  end

  update do
    1000.times do
      xn = Math.sin(@a * @y) - @c * Math.cos(@a * @x)
      yn = Math.sin(@b * @x) - @d * Math.cos(@b * @y)
      @x = xn
      @y = yn
      p0 = srect.center + [@x * srect.w * 0.2, @y * srect.h * 0.2]
      draw_dot(p0)
    end
  end

  def background_clear
  end

  run
end
