#
# sin/cosを一切使わずに回転する方法(角度0から)
#
require_relative "helper"

class App < Stylet::Base
  setup do
    @speed = (2 * Math::PI / (60 * 8))       # 角速度 (一周2πを120分割 = 8秒で一周想定)
    @r = srect.height / 4                     # 半径
    @p = vec2[@r, 0]           # 座標 (0度の状態では)
    @v = vec2[0, @r * @speed]  # 速度 (右端にいるのでy方向のベクトルだけが生きている)
  end

  update do
    a = @p * -@speed**2      # 加速度 = 現在の座標 * -角速度^2
    @v += a                    # 速度 += 加速度
    @p += @v                   # 座標 += 速度
    draw_vector(@p)
    vputs "@v: #{@v}"
  end

  run
end
