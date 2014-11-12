# -*- coding: utf-8 -*-
# 参照
# 「プログラムでシダを描画する」を Ruby で描画する - Qiita
# http://qiita.com/quanon86/items/d96cbea02800f97156e7

require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @n = 12
    @w1x = -> x, y { 0.836 * x + 0.044 * y }
    @w1y = -> x, y { -0.044 * x + 0.836 * y + 0.169 }
    @w2x = -> x, y { -0.141 * x + 0.302 * y }
    @w2y = -> x, y { 0.302 * x + 0.141 * y + 0.127 }
    @w3x = -> x, y { 0.141 * x - 0.302 * y }
    @w3y = -> x, y { 0.302 * x + 0.141 * y + 0.169 }
    @w4x = -> x, y { 0 }
    @w4y = -> x, y { 0.175337 * y }
  end

  update do
    f = -> (k, x, y) do
      if 0 < k
        f.(k - 1, @w1x.(x, y), @w1y.(x, y))
        f.(k - 1, @w2x.(x, y), @w2y.(x, y)) if rand < 0.3
        f.(k - 1, @w3x.(x, y), @w3y.(x, y)) if rand < 0.3
        f.(k - 1, @w4x.(x, y), @w4y.(x, y)) if rand < 0.3
      else
        xx = (x * 490 + srect.w * 0.5).to_i
        yy = (srect.h - y * 490).to_i
        draw_dot(vec2[xx, yy], :color => :green)
      end
    end

    -> k, x, y { f.(k, x, y) }.(@n, 0, 0)

    @n += (button.btA.repeat_0or1 - button.btB.repeat_0or1).to_i

    vputs "n: #{@n}"
  end

  run
end
