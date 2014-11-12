# -*- coding: utf-8 -*-
#
# マウスで円をアイスホッケーの球のように動かすアルゴリズム
#
require_relative "helper"

#
# 円の中心
#    p0 (見えない)
#      \
#       \ radius
#        \
#         座標 pos (見える)
#          方向 dir
#
class IceHockey < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    cursor.display = false

    @p0 = srect.center.clone # 物体の中心点
    @pos = @p0.clone        # 物体の位置
    @speed = 0              # 速度
    @radius = 0             # 中心からの移動量
    @dir = 0                # 中心からの移動角度
    @lock = false

    @body_radius = 64       # 物体の大きさ
    @speed_max = 16         # 速度最大
    @friction = 0.3         # 摩擦
  end

  update do
    # ボタンをクリックした瞬間に、
    if button.btA.trigger?
      # 自分の円のなかにカーソルがあればロックする
      if @pos.distance_to(mouse.point) < @body_radius
        @lock = true
      end
    end

    # ロックしているときに、ボタンが押されっぱなしなら
    if @lock && button.btA.press?
      @p0 = mouse.point.clone      # 円の座標をマウスと同じにする
      @power = mouse.vector.magnitude # マウスの直前からの移動距離を速度と考える
      @speed = 0                        # 速度を0とする
      @radius = 0                       # 半径を0とする
    end

    # ボタンが離された瞬間
    if button.btA.free_trigger?
      # ロックを解除する
      @lock = false
      # 速度が設定されていれば
      if @power
        @speed = @power             # 速度を円に反映し、
        @dir   = mouse.vector.angle # 円の方向にマウスが移動した方向を合わせる
        @power = nil                # 球が動いているときにボタンを連打すると @dir が再設定されてしまうので nil にしておく
      end
    end

    # 摩擦によって速度が落ちる
    @speed -= @friction

    # 速度調整
    @speed = Stylet::Etc.clamp(@speed, (0..@speed_max))

    # 速度反映
    @radius += @speed

    # 進んだ位置を計算
    _p = @p0 + vec2.angle_at(@dir) * @radius

    # 画面内なら更新
    if Stylet::CollisionSupport.rect_in?(srect, _p)
      @pos = _p
    end

    draw_circle(@pos, :radius => @body_radius, :vertex => 32)
    draw_line(@p0, @pos)
    vputs @power
    vputs @pos.distance_to(mouse.point)
    vputs @speed
    vputs @radius
  end

  run
end
