# -*- coding: utf-8 -*-
#
# ギャラガの敵の動き
#
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/stylet"))

class Ball
  def initialize(base, index)
    @base = base
    @index = index
  end

  def update
    p0 = pos_new(@base.count)      # 現在の位置を取得
    p1 = pos_new(@base.count.next) # 次のフレームの位置を取得
    dir = p0.rdirf(p1)             # 現在の位置から見て未来の角度を取得
    @base.draw_circle(p0, :radius => 20, :vertex => 3, :offset => dir) # 次に進む方向に向けて三角を表示
  end

  #
  # countフレーム地点の位置を取得
  #
  def pos_new(count)
    pos = Stylet::Point.new
    pos.x = @base.half_x + Stylet::Fee.rcosf(1.0 / 512 * (count * 3 + @index * 24)) * @base.half_x
    pos.y = @base.half_y + Stylet::Fee.rsinf(1.0 / 512 * (count * 4 + @index * 24)) * @base.half_y
    pos
  end
end

class App < Stylet::Base
  def before_main_loop
    super if defined? super
    @objects = Array.new(8){|i|Ball.new(self, i)}
  end

  def update
    super if defined? super
    @objects.each{|e|e.update}
  end
end

App.main_loop