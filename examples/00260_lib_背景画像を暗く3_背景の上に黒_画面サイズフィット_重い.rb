require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @image = SDL::Surface.load("assets/bg960x480_green_ruins.png").display_format
  end

  def background_clear
    # 画面サイズに合わせて画像表示
    SDL::Surface.transform_draw(
      @image,                     # これを
      screen,                     # ここに
      0,                          # 回転角度
      srect.w.to_f / @image.w,     # x倍率
      srect.h.to_f / @image.h,     # y倍率
      @image.w / 2, @image.h / 2, # 画像の拡大や回転の中心を
      srect.w / 2, srect.h / 2,     # 転送先のどこに合わせるか
      SDL::Surface::TRANSFORM_AA) # 綺麗フラグ

    # その上に黒
    screen.draw_rect(*srect, [0, 0, 0], true, 192)
  end

  run
end
