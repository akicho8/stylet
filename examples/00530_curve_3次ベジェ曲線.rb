# -*- coding: utf-8 -*-
require_relative "bezier"

class App
  def collection
    [
      [
        vec2.new(srect.min_x + srect.w / 8, srect.hy),              # 開始
        vec2.new(srect.min_x + srect.w / 4, srect.hy - srect.h / 4), # 制御(右)
        vec2.new(srect.max_x - srect.w / 4, srect.hy - srect.h / 4), # 制御(左)
        vec2.new(srect.max_x - srect.w / 8, srect.hy),              # 終了
      ]
    ]
  end

  # 三次ベジェ曲線
  #
  #   p0: 開始
  #   p1: 制御
  #   p2: 制御
  #   p3: 終了
  #
  #        p1           p2
  #   p0 ------------------- p3
  #
  #   用途
  #   ・激しく曲げたい
  #   ・終了座標を必ず通る必要がある
  #   ・計算量をまーまー少なくしたい
  #   ・クロスさせたい
  #
  def bezier_curve(p0, p1, p2, p3, d)
    o = vec2.zero
    o += p0.scale((1 - d) * (1 - d) * (1 - d))
    o += p1.scale(3 * d * (1 - d) * (1 - d))
    o += p2.scale(3 * d * d * (1 - d))
    o += p3.scale(d * d * d)
  end

  run
end
