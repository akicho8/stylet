# -*- coding: utf-8 -*-
#
# 放物線 狙撃 角度固定
#
# Flashゲーム講座＆ASサンプル集【狙撃の計算方法について】
# http://hakuhin.jp/as/shot.html#SHOT_02_01
#
# ・砲台の角度(45度ぐらいの範囲)の中に対象が入っていないと弾道がおかしくなる
#
require_relative "helper"

class Bullet
  include Stylet::Delegators

  attr_accessor :pos

  def initialize(pos, target, rot)
    @pos = pos.clone            # 自分の初期値
    @target = target            # 相手の初期値

    @rot = rot

    # どちらかを0にすると直線の軌跡になり指定フレームかけて二点間を移動することになる
    @g = 2.0   # 重力加速度
    @dt = 0.05 # 微分 (結局 y の差分は g * dt で出している)

    @speed = @target - @pos                # 対象までの差分

    t = -(2 * @speed.x * rsin(@rot)) / (rcos(@rot) * @g * @dt) + (2 * @speed.y / (@g * @dt))
    t = Math.sqrt(t.abs)

    @speed.x /= t
    @speed.y = @speed.x / rcos(@rot) * rsin(@rot)
  end

  def update
    @speed.y += @g * @dt         # Yの加速度が変化していく
    @pos += @speed

    unless @pos.to_a.any?(&:nan?)
      draw_triangle(@pos, :radius => 16, :angle => @speed.angle)
      draw_vector(@speed * 8, :origin => @pos) # スピードベクトルの可視化
      vputs "speed: #{@speed.round(2)}"
    end
  end

  def screen_out?
    @pos.to_a.any?(&:nan?) || @pos.y > srect.max_y
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "放物線 狙撃【角度固定】"

    @points = []
    @points << srect.center + vec2[+srect.w / 4, 0]  # 右の点

    @rot = Stylet::Fee.clock(10, 30)
  end

  update do
    update_movable_points(@points)
    @points.each_with_index {|e, i|vputs("p#{i}", :vector => e)}

    # アナログレバーの方向を向く
    if (joy = Stylet.context.joys.first) && (al = joy.adjusted_analog_levers[:right]) && al.magnitude >= 0.5
      if al.magnitude >= 0.5
        @rot = al.angle
      end
    end
    @rot += (1.0 / 24) * (button.btB.repeat_0or1 - button.btC.repeat_0or1)
    draw_vector(vec2.angle_at(@rot).scale(32), :origin => @points[0])

    # 球発射
    if frame_counter.modulo(30) == 1
      @objects << Bullet.new(@points[0], cursor.point, @rot)
    end
  end

  run
end
