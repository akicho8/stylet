# -*- coding: utf-8 -*-
#
# 円と円の反射
#
# 反射係数の関係(正面衝突したとする)
#
#   -(反射B - 反射A) / (衝突B - 衝突A) #=> 1.0
#
# 速度と質量を乗算すると運動量
#
#   運動量 = 質量 * 速度
#
# 運動量保存の法則により、衝突前の円の運動量の合計値と、衝突後の円の運動量の合計値は等しくなる
#
#   運動量保存の法則
#   質量A * 衝突A + 質量B * 衝突B = 質量A * 反射A + 質量B * 反射B
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  attr_reader :reflect_mode

  setup do
    self.title = "円と円の反射"
    cursor.vertex = 3

    @modes = ["reflect", "move", "none"]
    @reflect_mode = @modes.first

    @pA = srect.center.clone + vec2[80, -70]
    @sA = vec2.angle_at(Stylet::Fee.clock(6, 15)).scale(1.0)
    @a_radius = 100
    @am = @a_radius**2

    @pB = srect.center.clone + vec2[-120, -80]
    @sB = vec2.angle_at(Stylet::Fee.clock(4)).scale(1.0)
    @b_radius = 60
    @bm = @b_radius**2            # 質量

    @s_radius = 100 # 速度ベクトル 1.0 を画面上では何ドットで表わすか？
    @vertex = 32
    @reflect_ratio = 1.0 # 反射係数
  end

  update do
    if key_down?(SDL::Key::S)
      @reflect_mode = @modes[@modes.index(@reflect_mode).next.modulo(@modes.size)]
    end

    vputs "S:reflect=#{@reflect_mode}"
    vputs "Z:ray++ X:ray-- C:drag V:angle"

    # 操作
    begin
      # AとBで速度ベクトルの反映
      @pA += @sA.scale(button.btA.repeat_0or1) + @sA.scale(-button.btB.repeat_0or1)
      @pB += @sB.scale(button.btA.repeat_0or1) + @sB.scale(-button.btB.repeat_0or1)
      # Cボタンおしっぱなし + マウスで自機位置移動
      if button.btC.press?
        @pA = cursor.point.clone
      end
      # Dボタンおしっぱなし + マウスで自機角度変更
      if button.btD.press?
        if cursor.point != @pA
          @sA = (cursor.point - @pA).normalize * @sA.magnitude
        end
      end
    end

    # @pA += @sA
    # @pB += @sB

    @diff = @pB - @pA
    @rdiff = (@a_radius + @b_radius) - @diff.magnitude
    vputs "magnitude=#{@diff.magnitude}"
    vputs "rdiff=#{@rdiff}"

    # AとBをお互い離す
    if reflect_mode == "move"
      if @rdiff > 0
        @pA -= @diff.normalize * @rdiff / 2
        @pB += @diff.normalize * @rdiff / 2
      end
    end

    # 反射する
    if reflect_mode == "reflect"
      if @rdiff > 0
        begin
          # 反射するモードでもいったんお互いを引き離さないと絡まってしまう
          @pA -= @diff.normalize * @rdiff * 0.5
          @pB += @diff.normalize * @rdiff * 0.5

          # (am.x,am.y) 円Ａから円Ｂへ移動運動を発生させるベクトル
          # (ar.x,ar.y) 円Ａから円Ｂへ回転運動を発生させるベクトル
          # (bm.x,bm.y) 円Ｂから円Ａへ移動運動を発生させるベクトル
          # (br.x,br.y) 円Ｂから円Ａへ回転運動を発生させるベクトル

          # 速度ベクトルを重心方向と垂直な方向に分離する
          _denominator = (@diff.x**2 + @diff.y**2)

          # A
          # A→B 回転運動
          t = -(@diff.x * @sA.x + @diff.y * @sA.y) / _denominator

          ar = @sA + @diff.scale(t)

          # A→B 移動運動
          t = -(-@diff.y * @sA.x + @diff.x * @sA.y) / _denominator
          am = vec2[
            @sA.x - @diff.y * t,
            @sA.y + @diff.x * t,
          ]

          # B
          # B→A 回転運動
          t = -(@diff.x * @sB.x + @diff.y * @sB.y) / _denominator
          br = @sB + @diff.scale(t)

          # B→A 移動運動
          t = -(-@diff.y * @sB.x + @diff.x * @sB.y) / _denominator
          bm = vec2[
            @sB.x - @diff.y * t,
            @sB.y + @diff.x * t,
          ]

          # x 方向と y 方向それぞれの衝突後の速度を計算する
          ad = vec2[
            (@am * am.x + @bm * bm.x + bm.x * @reflect_ratio * @bm - am.x * @reflect_ratio * @bm) / (@am + @bm),
            (@am * am.y + @bm * bm.y + bm.y * @reflect_ratio * @bm - am.y * @reflect_ratio * @bm) / (@am + @bm),
          ]
          bd = vec2[
            -@reflect_ratio * (bm.x - am.x) + ad.x,
            -@reflect_ratio * (bm.y - am.y) + ad.y,
          ]

          # 回転運動を発生させるベクトルを加算して衝突後の速度を計算
          @sA.x = ad.x + ar.x
          @sA.y = ad.y + ar.y
          @sB.x = bd.x + br.x
          @sB.y = bd.y + br.y

          # @pA += @sA
          # @pB += @sB
        end
      end
    end

    draw_circle(@pA, :vertex => @vertex, :radius => @a_radius)
    vputs "A(#{@am})", :vector => @pA
    draw_vector(@sA.scale(@s_radius), :origin => @pA, :label => @sA.magnitude)

    draw_circle(@pB, :vertex => @vertex, :radius => @b_radius)
    vputs "B(#{@bm})", :vector => @pB
    draw_vector(@sB.scale(@s_radius), :origin => @pB, :label => @sB.magnitude)

    vputs "#{@sA.magnitude} + #{@sA.magnitude} = #{(@sA + @sB).magnitude}"

    if false
      if @resp = compute(@pA, @sA, @a_radius, @pB, @sB, @b_radius)
        vputs @resp.inspect
        vputs c_state(@resp)
      end

      if @resp
        @pA2 = @pA + @sA.normalize.scale(@resp[:f0])
        draw_circle(@pA2, :vertex => @vertex, :radius => @a_radius)

        @pB2 = @pB + @sB.normalize.scale(@resp[:f0])
        draw_circle(@pB2, :vertex => @vertex, :radius => @b_radius)
      end
    end
  end

  # hakuhin.jp/as/collide.html#COLLIDE_02
  #
  # 値                          状態
  # f0 と f1 がどちらもプラス   円同士は近づいている
  # f0 と f1 どちらもマイナス   円同士は離れている
  # f0 と f1 の符号が反転       円同士はめり込んでいる
  # f0 が 0 以上、 1 以下の値   現在のフレームで衝突する (この状態が発生しない。衝突は f0 == 0.0 && f1 > 0 のときっぽい←ちがう)
  #
  # Math.sqrt でエラーがでる
  # はなれすぎているとエラーになるみたい
  #
  def compute(ap, as, ar, bp, bs, br)
    _a = (as.x * as.x) - 2 * (as.x * bs.x) + (bs.x * bs.x) + (as.y * as.y) - 2 * (as.y * bs.y) + (bs.y * bs.y)
    _b = 2 * (ap.x * as.x) - 2 * (ap.x * bs.x) - 2 * (as.x * bp.x) + 2 * (bp.x * bs.x) + 2 * (ap.y * as.y) - 2 * (ap.y * bs.y) - 2 * (as.y * bp.y) + 2 * (bp.y * bs.y)
    _c = (ap.x * ap.x) - 2 * (ap.x * bp.x) + (bp.x * bp.x) + (ap.y * ap.y) - 2 * (ap.y * bp.y) + (bp.y * bp.y) - (ar + br) * (ar + br)
    _d = Math.sqrt(_b * _b - 4 * _a * _c)

    if _d <= 0
      # 当たりなし
      return
    end

    f0 = (- _b - _d) / (2 * _a) # 接触する瞬間
    f1 = (- _b + _d) / (2 * _a) # 離れる瞬間

    {:f0 => f0, :f1 => f1}
  rescue Errno::EDOM => error
    return
  end

  def c_state(resp)
    return unless resp
    # return if resp.is_a? StandardError
    if resp[:f0] > 0 && resp[:f1] > 0
      "tikazuki"
    elsif resp[:f0] < 0 && resp[:f1] < 0
      "hanare"
    elsif resp[:f0] >= 0 && resp[:f1] <= 1
      "collision"
      # elsif (resp[:f0] < 0 && resp[:f1] >= 0) || (resp[:f1] < 0 && resp[:f0] >= 0)
    elsif (resp[:f0] * resp[:f1]) < 0
      "merikomi"
    end
  end

  run
end
