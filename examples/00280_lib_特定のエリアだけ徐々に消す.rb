# 特定のエリアだけ徐々に消す
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @area_rc = vec2[srect.w / 2, srect.h / 2] # 表示エリアの横縦幅
    @image = SDL2::Surface.load("assets/bg960x480_green_ruins.png").display_format
  end

  update do
    draw_triangle(srect.center, :radius => 128, :angle => 1.0 / 256 * frame_counter)
  end

  def background_clear
    area_xy = *(cursor.point - (@area_rc / 2))                               # 表示エリアの左上を求める
    surface = screen.copy_rect(*area_xy, *@area_rc)                          # 表示部分を切り取る
    surface.draw_filled_rect_alpha(0, 0, surface.w, surface.h, [0, 0, 0], 8) # 切り取った部分を9割消す
    screen.put(@image, 0, 0)                                                 # 背景消去(画像で背景全体描画)
    screen.put(surface, *area_xy)                                            # 切り取って加工した部分を戻す(上書きする)
    surface.destroy                                                          # 作業用のサーフェスを消す(消さなくても動いた)
  end

  run
end
