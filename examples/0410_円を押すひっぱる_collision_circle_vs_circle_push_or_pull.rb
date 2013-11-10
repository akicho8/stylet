# -*- coding: utf-8 -*-
#
# 円同士の当り判定(ベクトルを使った方法)
#
require_relative "helper"

class Ball
  def initialize(win, pos)
    @win = win
    @pos = pos
    @radius = 100
  end

  def update
    a = @win.cursor.point
    ar = @win.cursor.radius

    b = @pos
    br = @radius

    r2 = ar + br
    if a != b
      diff = b - a
      rdiff = r2 - diff.magnitude
      if @win.button.btA.press?
        @win.vputs "PUSH"
        if rdiff > 0
          # a = b + diff.normalize * r2 # Bを基点に押し出す
          b += diff.normalize * rdiff    # Aを基点に押し出す
        end
      end
      if @win.button.btB.press?
        @win.vputs "PULL"
        if rdiff < 0
          # a = b + diff.normalize * r2 # Bを基点に戻す
          b += diff.normalize * rdiff    # Aを基点に戻す
        end
      end
      @win.vputs "DIFF=#{diff.magnitude}"
      @win.vputs "RDIFF=#{rdiff}"
    end

    @pos = b

    @win.draw_line(@pos, @win.cursor.point)
    @win.draw_circle(@pos, :radius => @radius, :vertex => 32)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  def before_run
    super if defined? super
    @objects << Ball.new(self, rect.center.clone)
    @cursor.radius = 100
    @cursor.vertex = 32
    self.title = "円の押し引き"
  end
end

App.run
