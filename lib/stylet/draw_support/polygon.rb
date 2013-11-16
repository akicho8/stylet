# -*- coding: utf-8 -*-
#
# 多角形描画
#
module Stylet
  module DrawSupport
    # 多角形描画
    #   draw_polygon([Vector.zero, Vector.new(0, 100), Vector.new(50, 50)])
    def draw_polygon(points, options = {})
      (points + [points.first]).each_cons(2) {|a, b| draw_line(a, b, options) }
    end
  end

  if $0 == __FILE__
    require_relative "../../stylet"
    Base.run do
      points = Array.new(3 + rand(3)){Vector.new(rand(rect.w), rand(rect.h))}
      draw_polygon(points)
      draw_polygon([Vector.zero, Vector.new(0, 100), Vector.new(50, 50)])
      sleep(0.25)
    end
  end
end
