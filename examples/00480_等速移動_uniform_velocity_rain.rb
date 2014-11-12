# -*- coding: utf-8 -*-
#
# 等速移動
#
#   いろんな多角形が落ちてくるだけ
#
require_relative "helper"

class Ball
  include Stylet::Delegators
  delegate :objects, :to => "Stylet.context"

  def initialize
    @gravity = Stylet::Vector.new(0, 0.05)

    @vertex = 3 + rand(3)
    @radius = 2 + rand(24)
    @arrow = rand(2).zero? ? 1 : -1

    @pos = Stylet::Vector.new(rand(srect.w), srect.min_y - @radius * 2)
    @speed = vec2.angle_at(Stylet::Fee.clock(rand(5.5..6.5))).scale(rand(1.0..1.5))
  end

  def update
    @pos += @speed

    # 落ちたら死ぬ
    max = srect.max_y + @radius * 2
    if @pos.y > max
      objects.delete(self)
    end

    draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * (@speed.magnitude + frame_counter) * @arrow)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    cursor.display = false
    self.title = "等速落下"
  end

  update do
    if frame_counter.modulo(4).zero?
      @objects << Ball.new
    end
  end

  run
end
