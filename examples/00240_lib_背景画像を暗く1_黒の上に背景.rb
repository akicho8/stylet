# 背景画像を暗くする方法1_黒背景にαブレンドで背景描画
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @image = SDL2::Surface.load("assets/bg960x480_green_ruins.png").display_format
    @image.set_alpha(SDL2::SRCALPHA, 64)
  end

  def background_clear
    super                             # 黒の背景を作る
    screen.put(@image, *cursor.point) # その上に重ねる
  end

  run
end
