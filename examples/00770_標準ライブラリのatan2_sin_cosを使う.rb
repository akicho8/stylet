require_relative "helper"

class App < Stylet::Base
  update do
    v = mouse.point - srect.center
    x, y = *v
    # 中央からカーソル位置への方向を取得
    rad = Math.atan2(y, x)
    # その方向にライン
    x = Math.cos(rad)
    y = Math.sin(rad)
    draw_line(srect.center, srect.center + vec2[x, y] * srect.height / 2)
  end
  run
end
