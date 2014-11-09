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
    update_movable_points([@point], :origin => rect.center)
    [@point, @point.prep].each.with_index{|e, i| draw_vector(e, :origin => rect.center, :label => "P#{i} #{e.round(2)}") }
    draw_vector(@point, :origin => rect.center)
    draw_vector(@point.prep, :origin => rect.center, :color => :orange)
  end

  run
end
