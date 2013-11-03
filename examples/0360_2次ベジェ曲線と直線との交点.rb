# -*- coding: utf-8 -*-
require_relative "bezier"

class App
  include LineCollision

  def collection
    [
      [
        rect.center + Stylet::Vector.new(-rect.w / 4, rect.h / 4),
        rect.center + Stylet::Vector.new(0, -rect.h / 4),
        rect.center + Stylet::Vector.new(rect.w / 4, rect.h / 4),
      ], [
        rect.center + Stylet::Vector.new(-100, +100),
        rect.center + Stylet::Vector.new(0, 0),
        rect.center + Stylet::Vector.new(+100, -100),
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
    o = Stylet::Vector.new(0, 0)
    o += p0.scale((1 - t) * (1 - t))
    o += p1.scale(2 * t * (1 - t))
    o += p2.scale(t * t)
  end

  run
end
