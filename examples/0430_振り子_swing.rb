# -*- coding: utf-8 -*-
#
# 振り子のアルゴリズム
#
# 円の中心
#    p0 ----- pA (鉄球) ----> dir1 (pAの方向)
#       \     ↓
#        \    ↓
#         \   ↓gravity (重力)
#          \  ↓
#           \ ↓
#             pB (重力を反映した座標) ※仮想鉄球
#             \
#              dir2 (pBの方向)
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "振り子"

    @p0 = rect.center + Stylet::Vector.new(0, -rect.h * 0)   # 円の中心
    @dir1 = Stylet::Fee.clock(1) # 角度
    @speed = 0                   # 角速度
    @friction = 0.0              # 摩擦(0.0:なし 1.0:最大)
    @radius = rect.hy * 0.5 # 糸の長さ
    @ball_radius = 32            # 鉄球自体の半径
    @dir2 = nil                  # 振り子の中心(p0)からの重力反映座標(pB)の角度
    @gravity = Stylet::Vector.new(0, 1)   # 重力加速度(整数で指定すること)
    @debug_mode = false
  end

  update do
    begin
      if button.btA.press? || button.btB.press?
        # 重力調整
        @gravity += @gravity.normalize.scale(button.btA.repeat) + @gravity.normalize.scale(-button.btB.repeat)
        @gravity.y = Stylet::Etc.range_limited(@gravity.y, (1..@radius))
        @speed = 0
      end

      # Aボタンが押されているときだけ鉄球の位置をカーソルの方向に向ける
      if button.btD.press?
        @dir1 = @p0.angle_to(cursor.point)
        @speed = 0
      end

      if button.btC.trigger?
        @debug_mode = !@debug_mode
      end
    end

    # 鉄球の座標(pA)を求める
    @pA = @p0 + Stylet::Vector.angle_at(@dir1).scale(@radius)

    # 鉄球の座標から重力を反映した座標(pB)を求める(pBを経由しなくてもpCは求まる)
    @pB = @pA + @gravity

    # 鉄球の座標から重力を反映した座標(pC)を求める(これはどういう数式？)
    v = @pA - @p0
    t = -(v.y * @gravity.y) / (v.x ** 2 + v.y ** 2)
    @pC = @pA + @gravity + v.scale(t)

    # 振り子の中心(p0)から重力反映座標(pC)の角度(@dir2)を求める
    @dir2 = @p0.angle_to(@pC)

    # 鉄球の角度が     dir1=0.9 (時計の14分の角度)
    # 仮想鉄球の角度が dir2=0.1 (時計の16分の角度)の場合、
    # 差分は正になるべきなのだけど
    # 差分を求めるために 0.1 - 0.9 をすると -0.8 になってしまい
    # 15分のあたりにいるのに逆向きに進もうとしてしまう。
    # これは15分の位置が一周の基点になっているためのおこる。
    # 対策として右半分にいるときかつ @dir2 の方が小さいとき @dir2 は一周したことにする
    # ただ 1.0 するのではなく @dir1 が進みすぎて一周したということにしたいので @dir1.round を加算してみたが、これはおかしくなる
    # 1.0 加算するのが正解っぽい
    if Stylet::Fee.cright?(@dir1)
      if @dir2 < @dir1
        @dir2 += 1.0
      end
    end

    # 仮想鉄球の角度と現在の角度の差を求める
    @diff = @dir2 - @dir1
    # @diff = (@pC - @pA).magnitude
    # vputs @diff

    # 加速
    @speed += @diff
    # 摩擦によって減速
    @speed *= (1.0 - @friction)
    # 進む
    @dir1 += @speed

    # 中心と鉄球の線
    draw_line(@p0, @pA)

    # 鉄球
    draw_circle(@pA, :radius => @ball_radius, :vertex => 16)

    # デバッグモード
    if @debug_mode || button.btD.press?
      # 仮想鉄球への紐
      draw_line(@p0, @pA)

      # 実鉄球から仮想鉄球への線
      # draw_line(@p0, @pB)
      draw_line(@p0, @pC) # 振り子の中心(p0)から重力反映座標(pC)への線を表示確認
      draw_line(@pA, @pB)
      draw_line(@pB, @pC)
      draw_line(@pA, @pC)
      vputs "P", :vector => @p0
      vputs "A", :vector => @pA
      vputs "B", :vector => @pB
      vputs "C", :vector => @pC

      # 90度ずらした線を引く
      rad90_line

      # 軌道の円周
      draw_circle(@p0, :radius => @radius, :vertex => 32)

      # draw_line(@pB, @pB + (@pA - @pB).scale(2))
    end

    vputs "dir1: #{@dir1}"
    vputs "dir2: #{@dir2}"
    vputs "diff: #{@diff}"
    vputs "speed: #{@speed}"
    vputs "gravity: #{@gravity.magnitude}"

    vputs "Z:g++ X:g-- C:debug V:drag"
  end

  # 90度ずらした線を引く
  def rad90_line
    # draw_line(@pB, @pC)
    # _r = 256
    # p2 = @pA + Stylet::Vector.angle_at(@dir1 - Stylet::Fee.r90) * _r
    # p3 = @pA + Stylet::Vector.angle_at(@dir1 + Stylet::Fee.r90) * _r
    # draw_line(p2, p3)
  end

  run
end
