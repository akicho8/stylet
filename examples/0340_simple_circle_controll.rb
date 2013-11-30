# -*- coding: utf-8 -*-
#
# 円の移動の定石
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "円の移動の定石"
    @pA = rect.center.clone
    @sA = Stylet::Vector.angle_at(Stylet::Fee.clock(8))
    @radius = 50
    @vertex = 32
  end

  update do
    # 操作
    # AとBで速度ベクトルの反映
    @pA += @sA.scale(button.btA.repeat_0or1) + @sA.scale(-button.btB.repeat_0or1)
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

    draw_circle(@pA, :vertex => @vertex, :radius => @radius)
    draw_vector(@sA.scale(@radius), :origin => @pA)
  end

  run
end
