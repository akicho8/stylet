# -*- coding: utf-8 -*-
# 標準ライブラリを使った場合の例
require_relative "helper"

class App < Stylet::Base
  update do
    one = 360                   # 一周を何度にしてもいい

    angle = frame_counter.modulo(one)
    vputs "角度: #{angle}"

    rad = angle * Math::PI / (one / 2)
    vputs "角度→ラジアン: #{rad}"
    x = Math.cos(rad)
    y = Math.sin(rad)
    draw_line(rect.center, rect.center + Stylet::Vector.new(x, y) * rect.height / 2)

    rad_to_angle = rad * (one / 2) / Math::PI
    vputs "ラジアン→角度: #{rad_to_angle}"
  end

  run
end
