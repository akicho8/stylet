# 背景画像を暗く3_背景の上に黒_画面サイズフィット_高速化
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  def screen_open
    super

    _image = SDL::Surface.load("assets/bg960x480_green_ruins.png").display_format

    # 画面サイズと同じバッファを作る
    temp_surface = screen.copy_rect(*srect)

    # 画面サイズに合わせて画像表示
    SDL::Surface.transform_draw(
      _image,                     # これを
      temp_surface,               # ここに
      0,                          # 回転角度
      srect.w.to_f / _image.w,     # x倍率
      srect.h.to_f / _image.h,     # y倍率
      _image.w / 2, _image.h / 2, # 画像の拡大や回転の中心を
      srect.w / 2, srect.h / 2,     # 転送先のどこに合わせるか
      SDL::Surface::TRANSFORM_AA) # 綺麗フラグ

    # その上に黒
    temp_surface.draw_rect(*srect, [0, 0, 0], true, 192)
    _image.destroy

    # リサイズで再び呼ばれている可能性があるため前回のを解放する
    if @image
      @image.destroy
    end

    @image = temp_surface
  end

  def background_clear
    # コピーを取ったものを毎回高速に描画
    screen.put(@image, *cursor.point)
  end

  run
end
