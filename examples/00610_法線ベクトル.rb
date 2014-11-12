# -*- coding: utf-8 -*-
#
# 法線ベクトル
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @point = Stylet::Vector.rand.normalize * 100
    self.title = "法線ベクトル"
  end

  update do
    update_movable_points([@point], :origin => srect.center)
    [@point, @point.prep].each.with_index{|e, i| draw_vector(e, :origin => srect.center, :label => "P#{i} #{e.round(2)}") }
    draw_vector(@point, :origin => srect.center)
    draw_vector(@point.prep, :origin => srect.center, :color => :orange)
  end

  run
end
