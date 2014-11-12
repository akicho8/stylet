# -*- coding: utf-8 -*-
#
# 3D
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @points = []

    @points << Stylet::Vector3.new(-200, +200, 75)
    @points << Stylet::Vector3.new(+200, +200, 75)
    @points << Stylet::Vector3.new(+200, -200, 75)
    @points << Stylet::Vector3.new(-200, -200, 75)

    @points << Stylet::Vector3.new(-200, +200, 50)
    @points << Stylet::Vector3.new(+200, +200, 50)
    @points << Stylet::Vector3.new(+200, -200, 50)
    @points << Stylet::Vector3.new(-200, -200, 50)

    @ridges = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0],

      [4, 5],
      [5, 6],
      [6, 7],
      [7, 4],

      [0, 4],
      [1, 5],
      [2, 6],
      [3, 7],
    ]

    @depth = 25
  end

  update do
    @depth += axis.down.repeat - axis.up.repeat
    points2 = @points.collect {|p| Stylet::Vector.new(p.x.to_f * @depth / p.z, p.y.to_f * @depth / p.z) }
    points3 = points2.collect {|p| srect.center + Stylet::Vector.new(p.x, -p.y) }
    @ridges.each {|a, b| draw_line(points3[a], points3[b]) }
    points3.each_with_index {|p0, index| vputs index, :vector => p0 }
    vputs "depth: #{@depth}"
  end

  run
end
