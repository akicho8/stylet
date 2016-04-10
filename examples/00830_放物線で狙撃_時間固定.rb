#
# 放物線 狙撃 時間固定
#
# Flashゲーム講座＆ASサンプル集【狙撃の計算方法について】
# http://hakuhin.jp/as/shot.html#SHOT_02_00
#
# ・反対側に行っても打てる
#
require_relative "helper"

class Bullet
  include Stylet::Delegators

  def initialize(pos, target)
    @pos = pos.clone            # 自分の初期値
    @target = target            # 相手の初期値

    @frames = 60 * 1.5           # 到達するまでのフレーム数(小さくすると早くなる)

    # どちらかを0にすると直線の軌跡になり指定フレームかけて二点間を移動することになる
    @g  = 2.0   # 上昇加速度(大きくすると高く上がる)
    @dt = 0.05  # 微分 (結局 y の差分は g * dt で出している)

    @speed = @target - @pos                # 対象までの差分
    @speed.y -= @frames**2 * (@g * @dt) / 2 # 上方向の加速度の初期値が求まる
    @speed /= @frames                       # フレーム数で分割

  end

  def update
    @speed.y += @g * @dt         # Yの加速度が変化していく
    @pos += @speed
    draw_triangle(@pos, :radius => 16, :angle => @speed.angle)
    draw_vector(@speed * 8, :origin => @pos) # スピードベクトルの可視化
  end

  def screen_out?
    @pos.y > srect.max_y
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "放物線 狙撃【時間固定】"
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
