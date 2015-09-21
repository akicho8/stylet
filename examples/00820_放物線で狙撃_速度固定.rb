# -*- coding: utf-8 -*-
#
# 放物線 狙撃 横方向のスピード固定
#
# Flashゲーム講座＆ASサンプル集【狙撃の計算方法について】
# http://hakuhin.jp/as/shot.html#SHOT_02_02
#
# ・反対側に行っても打てる
#
require_relative "helper"

class Bullet
  include Stylet::Delegators

  def initialize(pos, target)
    @pos = pos.clone            # 自分の初期値
    @target = target            # 相手の初期値

    # どちらかを0にすると直線の軌跡になり指定フレームかけて二点間を移動することになる
    @g  = 2.0   # 上昇加速度(大きくすると高く上がる)
    @dt = 0.05  # 微分 (結局 y の差分は g * dt で出している)

    diff = @target - @pos
    dx = 5                      # X方向の速度
    if diff.x < 0               # Flashゲーム講座の説明のコードではこれがなくなっていた
      dx = -dx
    end
    t = diff.x / dx             # t = 到達までのフレーム数
    dy = (diff.y - t**2 * (@g * @dt) / 2) / t
    @speed = vec2[dx, dy]
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
    self.title = "放物線 狙撃【横方向の速度固定】"
    @points = []
    @points << srect.center + vec2[+srect.w / 4, 0]
  end

  update do
    update_movable_points(@points)
    @points.each_with_index {|e, i|vputs("p#{i}", :vector => e)}
    if frame_counter.modulo(30) == 1
      @objects << Bullet.new(@points[0], cursor.point)
    end
  end

  run
end
