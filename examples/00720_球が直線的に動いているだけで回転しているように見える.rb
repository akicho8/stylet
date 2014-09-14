# -*- coding: utf-8 -*-
# 球が直線的に動いているだけで回転しているように見える
# http://www.gizmodo.jp/2014/07/post_15084.html
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @n = 20                     # 球の数
    @ball_r = 8                 # 球の半径
    @diff = 1.0
  end

  update do
    @diff += 0.01 * (button.btA.repeat - button.btB.repeat)

    @n.times do |i|
      r = rsin(0.5 / @n * i + 1.0 / 256 * frame_counter * 1) * rect.h * 0.45
      pos = Stylet::Vector.angle_at(0.5 / @n * i * @diff) * r
      draw_circle(rect.center + pos, :radius => @ball_r, :vertex => 8)
    end

    draw_circle(rect.center, :radius => rect.h * 0.45 + @ball_r, :vertex => 20)
  end

  run
end
