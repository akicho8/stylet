# -*- coding: utf-8 -*-
# シグモイド関数 - Wikipedia
# http://ja.wikipedia.org/wiki/%E3%82%B7%E3%82%B0%E3%83%A2%E3%82%A4%E3%83%89%E9%96%A2%E6%95%B0
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @points = []
    @points << rect.center + Stylet::Vector.new(-rect.w * 0.4, rect.h * 0.4)
    @points << rect.center + Stylet::Vector.new( rect.w * 0.4, -rect.h * 0.4)
    @gain = 8                   # 0で水平、8ぐらいでS時、マイナスなら反転
  end

  update do
    update_movable_points(@points)
    @points.each_with_index{|e, i|vputs("p#{i}", :vector => e)}

    p0, p1 = *@points
    if p0.x > p1.x              # 動かしていて左から順に p1 p0 になってしまったときは p0 p1 となるように入れ替える
      p1, p0 = *@points
    end
    n = p1.x - p0.x
    n.to_i.times.each do |x|
      y = -sigmoid(@gain, 2.0 / n * x - 1.0) * (p0.y - p1.y)
      draw_dot(p0 + [x, y])
    end

    @gain += 0.1 * (button.btB.repeat - button.btC.repeat)

    vputs "gain: #{@gain.round(1)}"
  end

  def sigmoid(gain, x)
    1.0 / (1.0 + Math.exp(-gain * x))
  end

  run
end
