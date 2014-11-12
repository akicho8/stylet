# -*- coding: utf-8 -*-
#
# 円の動き
#
require_relative "helper"

class Ball
  def initialize(win)
    @win = win
  end

  def update
    pos = Stylet::Vector.zero
    pos.x = Stylet::Fee.rcos(1.0 / 512 * (@win.frame_counter * 3)) * @win.srect.w / 2
    pos.y = Stylet::Fee.rsin(1.0 / 512 * (@win.frame_counter * 4)) * @win.srect.h / 2
    pos += @win.srect.center
    @win.draw_polygon(pos, :radius => 64)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @cursor.display = false
    @objects << Ball.new(self)
  end

  run
end
