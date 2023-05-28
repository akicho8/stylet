# 画像を切り替えるだけのアニメーション
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL2::Surface.load("assets/coin_anim_x4.png") # 16x16 x 横4
    s.set_color_key(SDL2::SRCCOLORKEY, 0)
    @image = s.display_format
  end

  update do
    SDL2::Surface.blit(@image, (frame_counter / 8).modulo(4) * 16, 0, 16, 16, screen, *srect.center)
  end

  run
end
