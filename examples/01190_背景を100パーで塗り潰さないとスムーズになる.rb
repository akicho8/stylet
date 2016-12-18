# 背景を100%で塗り潰さないとスムーズになる
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  update do
    draw_triangle(mouse.point, :radius => 128, :angle => 1.0 / 256 * frame_counter)
  end

  def background_clear
    screen.draw_filled_rect_alpha(*srect, [0, 0, 0], 8)
  end

  run
end
