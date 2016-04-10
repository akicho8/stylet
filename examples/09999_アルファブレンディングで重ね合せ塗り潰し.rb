# 重ね合せ塗り潰し アルファブレンディング
require "./setup"

class App < Stylet::Base
  update do
    screen.draw_filled_rect_alpha( 0,  0, 100, 100, [255, 255, 255], 128)
    screen.draw_filled_rect_alpha(50, 50, 100, 100, [255, 255, 255], 128)
  end

  run
end
