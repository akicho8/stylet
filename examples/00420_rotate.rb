# -*- coding: utf-8 -*-
#
# Vector#rotate の確認
#
require "./setup"

pos1 = Stylet::Vector.new(100, 0)
pos2 = Stylet::Vector.new(100, 0)
Stylet.run(:title => "Vector#rotate系の二つのメソッドの確認") do
  pos1 = pos1.rotate(1.0 / 256)
  pos2 = pos2.rotate2(1.0 / 256)
  vputs(pos1 == pos2)
  vputs "1: #{pos1}"
  vputs "2: #{pos2}"
  draw_triangle(rect.center + pos1, :radius => 64, :angle => pos1.angle)
  draw_triangle(rect.center + pos2, :radius => 64, :angle => pos2.angle)
end
