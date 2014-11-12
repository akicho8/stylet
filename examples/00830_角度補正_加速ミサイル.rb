# -*- coding: utf-8 -*-
# カーソルの位置に補正していくミサイル

require_relative "helper"

class Bullet
  include Stylet::Delegators

  def initialize(pos:, target:)
    @pos = pos
    @target = target
    @dir = rand

    @speed = 3                  # 初速度
    @accel = 0.1                # 増減する加速度
    @angle_window = 1.0 / 4     # 360 / 8 = 45 度未満ならターゲットの方向を向いていると考える
    @adir = 0.06                # 相手の方向に補正していく速度(1.0:最速)
  end

  def update
    d = Stylet::Fee.angle_diff(from: @dir, to: @pos.angle_to(@target))
    @dir += d * @adir

    if d.abs < @angle_window   # angle_window 度未満なら
      @speed += @accel         # 相手の方向に向いているとして速度を上げる
    else
      @speed -= @accel         # そうでないなら速度を下げる
    end
    @speed = Stylet::Etc.clamp(@speed, 1.0..8.0) # 速度が下がりすぎたり上がりすぎたりするのを防ぐ

    speed_vec = vec2.angle_at(@dir) * @speed
    @pos += speed_vec
    draw_triangle(@pos, :radius => 10, :angle => @dir)
    draw_vector(speed_vec * 4, :origin => @pos) # スピードベクトルの可視化

    if (@target - @pos).length < 16
      Stylet.context.objects.delete(self)
    end
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "角度補正ミサイル"
    @points = []
    @points << srect.center + Stylet::Vector.new(+srect.w / 4, 0)
  end

  update do
    update_movable_points(@points)
    @points.each_with_index{|e, i|vputs("p#{i}", :vector => e)}
    if frame_counter.modulo(30).zero?
      @objects << Bullet.new(:pos => @points[0], :target => cursor.point)
    end
  end

  run
end
