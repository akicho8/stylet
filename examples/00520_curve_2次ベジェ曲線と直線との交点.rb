# -*- coding: utf-8 -*-
require_relative "bezier"

class App
  include LineCollision

  def collection
    [
      [
        srect.center + vec2.new(-srect.w / 4, srect.h / 4),
        srect.center + vec2.new(0, -srect.h / 4),
        srect.center + vec2.new(srect.w / 4, srect.h / 4),
      ], [
        srect.center + vec2.new(-100, +100),
        srect.center + vec2.zero,
        srect.center + vec2.new(+100, -100),
      ],
    ]
  end

  # 二次ベジェ曲線
  #
  #   p0: 開始座標
  #   p1: 制御座標
  #   p2: 終了座標
  #
  #              p1
  #   p0 ------------------- p2
  #
  #   用途
  #   ・少し曲げたい
  #   ・終了座標を必ず通る必要がある
  #   ・計算量をなるべく少なくしたい
  #   ・クロスしなくてよい
  #
  def bezier_curve(p0, p1, p2, t)
    o = vec2.zero
    o += p0.scale((1 - t) * (1 - t))
    o += p1.scale(2 * t * (1 - t))
    o += p2.scale(t * t)
  end

  run
end
