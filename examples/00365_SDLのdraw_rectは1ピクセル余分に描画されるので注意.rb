# -*- coding: utf-8 -*-
require "./setup"

Stylet.run do
  color = [255] * 3
  screen.fill_rect(*(rect.center + [0, 8 * 2]), 1, 1, color) # 1x1 で 1 ピクセル
  screen.draw_rect(*(rect.center + [0, 8 * 1]), 0, 0, color) # draw_rect は 幅 0x0 なのに 1 ピクセル描画されてしまう
end
