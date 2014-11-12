# -*- coding: utf-8 -*-
#
# 円と点の反射
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    cursor.radius = 1

    @radius = 64                # 円の半径

    @pos = Stylet::Vector.new(srect.center.x, srect.max_y)           # 物体初期位置
    @speed = Stylet::Vector.new(rand(-2.0..2.0), rand(-15.0..-12)) # 速度ベクトル
    @gravity = Stylet::Vector.new(0, 0.220)                        # 重力
  end

  update do
    @speed += @gravity
    @pos += @speed

    diff = @pos - cursor.point
    if diff.magnitude > 0
      if diff.magnitude < @radius
        @pos = cursor.point + diff.normalize.scale(@radius)
        @speed = diff.normalize * @speed.magnitude
      end
    end

    draw_circle(@pos, :radius => @radius, :vertex => 32)
    vputs "Z:x++ X:x--"
  end

  run
end
