# -*- coding: utf-8 -*-
#
# 円と点の反射
#
require_relative "helper"

class Circle
  def initialize(win)
    @win = win

    @radius = 64                                     # 円の半径

    @pos = Stylet::Vector.new(@win.rect.center.x, @win.rect.max_y)             # 物体初期位置
    @speed = Stylet::Vector.new(rand(-2.0..2.0), rand(-15.0..-12)) # 速度ベクトル
    @gravity = Stylet::Vector.new(0, 0.220)                                                        # 重力
  end

  def update
    @speed += @gravity
    @pos += @speed

    diff = @pos - @win.cursor.point
    if diff.magnitude > 0
      if diff.magnitude < @radius
        @pos = @win.cursor.point + diff.normalize.scale(@radius)
        @speed = diff.normalize * @speed.magnitude
      end
    end

    @win.draw_circle(@pos, :radius => @radius, :vertex => 32)
    @win.vputs "Z:x++ X:x--"
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @objects << Circle.new(self)
    @cursor.radius = 1
  end

  run
end
