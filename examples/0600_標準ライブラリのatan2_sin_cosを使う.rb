# -*- coding: utf-8 -*-
require_relative "helper"

class App < Stylet::Base
  update do
    v = mouse.point - rect.center
    x, y = v.to_a
    # 中央からカーソル位置への方向を取得
    rad = Math.atan2(y, x)
    # その方向にライン
    x = Math.cos(rad)
    y = Math.sin(rad)
    draw_line(rect.center, rect.center + Stylet::Vector.new(x, y) * rect.height / 2)
  end
  run
end
