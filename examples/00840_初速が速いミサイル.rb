# -*- coding: utf-8 -*-
# カーソルの位置に補正していくミサイル

require_relative "helper"

class Bullet
  include Stylet::Delegators

  def initialize(pos:, target:)
    @pos = pos
    @target = target
    @dir = rand

    @speed = 0                  # 初速度
  end

  def update
    @dir = @pos.angle_to(@target)
    len = (@target - @pos).length
    speed = len * 0.04
    speed = Stylet::Etc.clamp(speed, 3.0..12.0)
    speed_vec = vec2.angle_at(@dir) * speed
    @pos += speed_vec
    draw_triangle(@pos, :radius => 10, :angle => @pos.angle_to(@target))
    draw_vector(speed_vec * 2, :origin => @pos) # スピードベクトルの可視化

    if (@target - @pos).length < 16
      Stylet.context.objects.delete(self)
    end
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "俊足ミサイル"
    @points = []
    @points << srect.center + vec2[+srect.w / 4, 0]
  end

  update do
    update_movable_points(@points)
    @points.each_with_index{|e, i|vputs("p#{i}", :vector => e)}
    if frame_counter.modulo(10).zero?
      @objects << Bullet.new(:pos => @points[0], :target => cursor.point)
    end
  end

  run
end
