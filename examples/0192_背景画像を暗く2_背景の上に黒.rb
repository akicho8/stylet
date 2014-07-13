# -*- coding: utf-8 -*-
# 背景画像を暗くする方法2_背景の上に黒を薄く
require "./setup"

class App < Stylet::Base
  setup do
    @image = SDL::Surface.load("assets/bg960x480_green_ruins.png").display_format
  end

  def background_clear
    screen.put(@image, 0, 0)         # 画像表示
    screen.draw_rect(rect.x, rect.y, rect.w / 2, rect.h, [0, 0, 0], true, 192) # その上に黒
  end

  run
end
