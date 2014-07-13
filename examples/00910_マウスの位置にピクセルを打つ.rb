# -*- coding: utf-8 -*-
# マウスの位置にピクセルを打つ
require_relative "helper"

class App < Stylet::Base
  setup do
    SDL::Mouse.hide
  end

  update do
    screen[*mouse.point] = screen.format.map_rgb(*3.times.collect{rand(255)})
  end

  def background_clear
  end

  run
end
