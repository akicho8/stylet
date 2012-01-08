# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "bezier"))

class BezierUnit
  include BezierUnitBase

  def setup
    @mpoints << MovablePoint.new(self, Stylet::Vector.new(@win.srect.min_x + @win.srect.w / 8, @win.srect.half_y))                    # 開始
    @mpoints << MovablePoint.new(self, Stylet::Vector.new(@win.srect.min_x + @win.srect.w / 4, @win.srect.half_y - @win.srect.h / 4)) # 制御(右)
    @mpoints << MovablePoint.new(self, Stylet::Vector.new(@win.srect.max_x - @win.srect.w / 4, @win.srect.half_y - @win.srect.h / 4)) # 制御(左)
    @mpoints << MovablePoint.new(self, Stylet::Vector.new(@win.srect.max_x - @win.srect.w / 8, @win.srect.half_y))                    # 終了
  end

  # 三次ベジェ曲線
  #
  #   p0: 開始
  #   p1: 制御
  #   p2: 制御
  #   p2: 終了
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
  def bezier_point(points, d)
    o = Stylet::Vector.new(0, 0)
    o += points[0].scale((1 - d) * (1 - d) * (1 - d))
    o += points[1].scale(3 * d * (1 - d) * (1 - d))
    o += points[2].scale(3 * d * d * (1 - d))
    o += points[3].scale(d * d * d)
  end
end

App.main_loop