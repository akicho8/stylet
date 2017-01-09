require "./setup"

class App < Stylet::Base
  update do
    screen.draw_filled_rect_alpha( 0,  0, 100, 100, [255, 255, 255], 128)
    screen.draw_filled_rect_alpha(50, 50, 100, 100, [255, 255, 255], 128)


    # screen.fill_rect(*(srect.center + [0, 8 * 2]), 1, 1, color) # 1x1 で 1 ピクセル
    # screen.draw_rect(*(srect.center + [0, 8 * 1]), 0, 0, color) # draw_rect は 幅 0x0 なのに 1 ピクセル描画されてしまう
    
    
  end

  run
end
