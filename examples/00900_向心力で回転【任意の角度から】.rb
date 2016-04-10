#
# sin/cosを一切使わずに回転【任意の角度から】
#
require_relative "helper"

class App < Stylet::Base
  setup do
    @speed = (2 * Math::PI / (60 * 8))       # 角速度 (一周2πを120分割 = 8秒で一周想定)

    @r = 100                                 # 半径
    @p = vec2.angle_at(Stylet::Magic.r45) * @r # 座標(45度=右下)

    # 速度の求め方
    # vx = -rω * sin(ωt)
    # vy = rω * cos(ωt)
    t = Math.atan2(@p.y, @p.x) / @speed     # tフレーム目
    @v = vec2[
      -@r * @speed * Math.sin(@speed * t),
      +@r * @speed * Math.cos(@speed * t),
    ]
    # ※ 0, 90, 180, 270 度から始まるなら sin cos は不要になる
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
