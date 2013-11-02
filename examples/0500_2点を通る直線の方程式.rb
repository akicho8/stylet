# -*- coding: utf-8 -*-
#
# 2点を通る直線の方程式
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  def before_run
    super
    @p1 = rect.center + Stylet::Vector.new(-rect.w / 4, rand(rect.h / 4)) # 左の点
    @p2 = rect.center + Stylet::Vector.new(+rect.w / 4, rand(rect.h / 4)) # 右の点
    self.title = "2点を通る直線の方程式"
    @x_mode = true
  end

  def update
    super

    # A, B ボタンでそれぞれ移動
    @p1 = mouse.point.clone if button.btA.press?
    @p2 = mouse.point.clone if button.btB.press?

    if button.btC.trigger?
      @x_mode = !@x_mode
    end

    if @x_mode
      # X軸を等速で動かしてYを求める場合
      x_range = ((rect.center.x - rect.w / 4) .. (rect.center.x + rect.w / 4))
      x_range.begin.step(x_range.end, 16) do |x|
        y = (((@p2.y - @p1.y).to_f / (@p2.x - @p1.x)) * (x - @p1.x)) + @p1.y
        v = Stylet::Vector.new(x, y)
        draw_triangle(v, :radius => 4, :vertex => 4)
      end
    else
      # Y軸を等速で動かしてXを求める場合
      y_range = ((rect.center.y - rect.h / 4) .. (rect.center.y + rect.h / 4))
      y_range.begin.step(y_range.end, 16) do |y|
        x = (((y - @p1.y) * (@p2.x - @p1.x)).to_f / (@p2.y - @p1.y)) + @p1.x
        v = Stylet::Vector.new(x, y)
        draw_triangle(v, :radius => 4, :vertex => 4)
      end
    end

    vputs "p1:#{@p1.to_a}"
    vputs "p2:#{@p2.to_a}"
    vputs "A:left point move B:right point move C:x y toggle"

    draw_triangle(@p1, :radius => 16)
    draw_triangle(@p2, :radius => 16)
    vputs("p1", :vector => @p1)
    vputs("p2", :vector => @p2)
  end

  run
end
