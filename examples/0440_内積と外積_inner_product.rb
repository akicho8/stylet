# -*- coding: utf-8 -*-
#
# 内積
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  before_main_loop do
    @points = []
    @points << Stylet::Vector.angle_at(Stylet::Fee.clock(3)).scale(100)
    @points << Stylet::Vector.angle_at(Stylet::Fee.clock(0)).scale(100)
    self.title = "内積と外積"
  end

  after_update do
    movable_point_update(@points, :origin => rect.center)
    @points.each.with_index{|e, i| draw_vector(e, :origin => rect.center, :label => "P#{i} #{e.round(2)}") }

    a, b = @points
    # Bを動かしているときにはAをnormalizeした方がわかりやすい
    inner_product = Stylet::Vector.inner_product(a.normalize, b)
    cross_product = Stylet::Vector.cross_product(a.normalize, b)

    vputs "内積(横): #{inner_product.round(2)}"
    vputs "外積(縦): #{cross_product.round(2)}"

    vC = a.normalize * inner_product
    vD = a.normalize.rotate(Stylet::Fee.r90) * cross_product
    draw_vector(vC, :origin => rect.center, :color => "orange")
    draw_vector(vD, :origin => vC + rect.center, :color => "orange")
  end

  run
end
