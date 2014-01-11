# -*- coding: utf-8 -*-
#
# 等速移動
#
#   いろんな多角形が落ちてくるだけ
#
require_relative "helper"

class Ball
  def initialize
    @gravity = Stylet::Vector.new(0, 0.05)

    @vertex = 3 + rand(3)
    @radius = 2 + rand(24)
    @arrow = rand(2).zero? ? 1 : -1

    @pos = Stylet::Vector.new(rand(__frame__.rect.w), __frame__.rect.min_y - @radius * 2)
    @speed = Stylet::Vector.angle_at(Stylet::Fee.clock(rand(5.5..6.5))).scale(rand(1.0..1.5))
  end

  def update
    @pos += @speed

    # 落ちたら死ぬ
    max = __frame__.rect.max_y + @radius * 2
    if @pos.y > max
      __frame__.objects.delete(self)
    end

    __frame__.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * (@speed.magnitude + __frame__.count) * @arrow)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    cursor.display = false
    self.title = "等速落下"
  end

  update do
    if @count.modulo(4).zero?
      @objects << Ball.new
    end
  end

  run
end
