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

    @pos = Stylet::Vector.new(rand(Stylet.context.rect.w), Stylet.context.rect.min_y - @radius * 2)
    @speed = Stylet::Vector.angle_at(Stylet::Fee.clock(rand(5.5..6.5))).scale(rand(1.0..1.5))
  end

  def update
    @pos += @speed

    # 落ちたら死ぬ
    max = Stylet.context.rect.max_y + @radius * 2
    if @pos.y > max
      Stylet.context.objects.delete(self)
    end

    Stylet.context.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * (@speed.magnitude + Stylet.context.count) * @arrow)
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
