# -*- coding: utf-8 -*-
#
# ギャラガの敵の動き
#
require_relative "helper"

class Ball
  def initialize(index)
    @index = index
  end

  def update
    p0 = pos_new(Stylet.context.count)      # 現在の位置を取得
    p1 = pos_new(Stylet.context.count.next) # 次のフレームの位置を取得
    dir = p0.angle_to(p1)          # 現在の位置から見て未来の角度を取得
    Stylet.context.draw_circle(p0, :radius => 20, :vertex => 3, :angle => dir) # 次に進む方向に向けて三角を表示
  end

  #
  # countフレーム地点の位置を取得
  #
  def pos_new(count)
    pos = Stylet::Vector.new
    pos.x = Stylet::Fee.rcos(1.0 / 512 * (count * Stylet.context.xc + @index * 24)) * Stylet.context.rect.w * 0.4
    pos.y = Stylet::Fee.rsin(1.0 / 512 * (count * Stylet.context.yc + @index * 24)) * Stylet.context.rect.h * 0.4
    Stylet.context.rect.center + pos
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  attr_reader :xc, :yc

  setup do
    cursor.display = false
    @objects += Array.new(16){|i|Ball.new(i)}
    @xc = 3.5
    @yc = 4.0
  end

  update do
    @xc += 0.5 * (@button.btA.repeat + -@button.btB.repeat)
    @yc += 0.5 * (@button.btC.repeat + -@button.btD.repeat)
    vputs [@xc, @yc]
  end

  run
end
