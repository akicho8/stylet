# 背景画像を暗くする方法2_背景の上に黒を薄く
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @image = SDL2::Surface.load("assets/bg960x480_green_ruins.png").display_format
  end

  def background_clear
    screen.put(@image, *cursor.point) # 画像表示
    screen.draw_rect(srect.x, srect.y, srect.w / 2, srect.h, [0, 0, 0], true, 192) # その上に黒
  end

  run
end
