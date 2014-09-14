# -*- coding: utf-8 -*-
#
# マウスの位置からZボタンで放物線を描く三角を表示
#
require_relative "helper"

class Ball
  def initialize(p0, speed, friction)
    @p0 = p0
    @speed = speed
    @friction = friction
  end

  def update
    @speed += @friction
    @p0 += @speed
    Stylet.context.draw_triangle(@p0, :radius => 16, :angle => 1.0 / 64 * Stylet.context.frame_counter)
  end

  def screen_out?
    @speed.y > 0 && @p0.y > (Stylet.context.rect.max_y + @radius)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  update do
    if button.btA.counter.modulo(4) == 1
      @objects << Ball.new(cursor.point.clone, Stylet::Vector.new(0, -12), Stylet::Vector.new(0, 0.2))
    end
  end

  run
end
