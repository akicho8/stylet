# -*- coding: utf-8 -*-
#
# つくりかけ
#
# 直線の式 | 中学から数学だいすき！
# http://mtf.z-abc.com/?eid=518185

require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  def before_run
    super
    @a = 0.0
    @b = 0.0
    @c = 0.0
  end

  def update
    super

    vputs "a:#{@a}"
    vputs "a:#{@b}"
    vputs "a:#{@c}"

    @a += (1.0 * (button.btA.repeat - button.btB.repeat))
    @b += (1.0 * (button.btC.repeat - button.btD.repeat))
    @c = 0.0

    0.step(200, 5) do |x|
      # ax + by + c = 0
      # by = -ax - c
      # y  = (-a / b) * x - c / b
      y = (-@a / @b) * x - @c / @b
      v = rect.center + Stylet::Vector.new(x, y)
      draw_triangle(v, :radius => 1)
    end
  end

  run
end
