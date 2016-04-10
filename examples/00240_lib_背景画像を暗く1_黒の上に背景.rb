# 背景画像を暗くする方法1_黒背景にαブレンドで背景描画
require "./setup"

class App < Stylet::Base
  setup do
    @image = SDL::Surface.load("assets/bg960x480_green_ruins.png").display_format
    @image.set_alpha(SDL::SRCALPHA, 64)
  end

  def background_clear
    super                       # 黒の背景を作る
    screen.put(@image, 0, 0)    # その上に重ねる
  end

  run
end
