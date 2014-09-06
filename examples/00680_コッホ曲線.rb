# -*- coding: utf-8 -*-
#
# 再帰プログラムによるフラクタル図形の描画：CodeZine
# http://codezine.jp/article/detail/73

require_relative "helper"

class Koch < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @power = 3
    @vertex_n = 15
  end

  update do
    @power += button.btA.repeat - button.btB.repeat
    @vertex_n += button.btC.repeat - button.btD.repeat

    @vertex_n.times.each{|i|
      get_pos = proc {|i|
        a = (1.0 * count / (60 * 60)) + (1.0 / @vertex_n * i)
        Stylet::Vector.angle_at(a * 7, a * 8) * rect.h * 0.4
      }
      # draw_vector get_pos[i], :origin => rect.center
      koch_draw(rect.center + get_pos[i], rect.center + get_pos[i.next], @power)
    }
    vputs "power: #{@power}"
    vputs "vertex_n: #{@vertex_n}"
  end

  def koch_draw(a, b, n)
    c = vec2.new
    d = vec2.new
    e = vec2.new

    c.x = (2 * a.x + b.x) / 3
    c.y = (2 * a.y + b.y) / 3
    d.x = (a.x + 2 * b.x) / 3
    d.y = (a.y + 2 * b.y) / 3
    xx = b.x - a.x
    yy = -(b.y - a.y)

    if xx.zero?
      return
    end

    distance = Math.sqrt(xx * xx + yy * yy) / Math.sqrt(3)

    if xx >= 0
      # 右上がり
      angle = Math.atan(yy / xx) + Math::PI / 6
      e.x = a.x + distance * Math.cos(angle)
      e.y = a.y - distance * Math.sin(angle)
    else
      angle = Math.atan(yy / xx) - Math::PI / 6
      e.x = b.x + distance * Math.cos(angle)
      e.y = b.y - distance * Math.sin(angle)
    end

    if n <= 0
      draw_line(a, c)
      draw_line(c, e)
      draw_line(e, d)
      draw_line(d, b)
    else
      koch_draw(a, c, n - 1)
      koch_draw(c, e, n - 1)
      koch_draw(e, d, n - 1)
      koch_draw(d, b, n - 1)
    end
  end

  run
end
