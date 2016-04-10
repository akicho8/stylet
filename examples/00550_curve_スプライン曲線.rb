#
# スプラインの描画
#
# Flashゲーム講座＆ASサンプル集【曲線について】
# http://hakuhin.jp/as/curve.html#CURVE_04
#
require_relative "helper"

class SprineApp < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "スプライン曲線"
    @points = 5.times.collect { srect.center + vec2.rand * srect.height * 0.5}
  end

  update do
    a = spline_stream(@points, 256) # 点と点の間をN分割する
    a.each_cons(2) {|a, b| draw_line(a, b) }
    update_movable_points(@points)
    @points.each_with_index {|e, i| vputs("#{i}", :vector => e) }
    ship(a)
  end

  def ship(a)
    # 区間をN分割なので角に来るとブレーキがかかる感じになる
    t0 = 0.5 + (Stylet::Fee.rsin(1.0 / 256 / 4 * (frame_counter + 0)) * 0.5) # 現在の位置(0.0〜1.0)
    t1 = 0.5 + (Stylet::Fee.rsin(1.0 / 256 / 4 * (frame_counter + 16)) * 0.5) # 現在の位置(0.0〜1.0)
    p0 = a[((a.size - 1).to_f * t0).to_i]                            # 現在の座標
    p1 = a[((a.size - 1).to_f * t1).to_i]                            # 現在の座標
    draw_triangle(p0, :angle => p0.angle_to(p1), :vertex => 3)
  end

  # a-b-c の場合 a-b b-c 区間をそれぞれ interpolate 分割する
  def spline_stream(points, interpolate)
    num = points.length
    l = []
    _a = []
    _b = []
    _c = []

    (num - 1).times {|i|
      p0 = points[i]
      p1 = points[i + 1]
      l[i] = Math.sqrt((p0.x - p1.x) * (p0.x - p1.x) + (p0.y - p1.y) * (p0.y - p1.y))
    }

    _a[0] = [0, 1, 0.5]
    _b[0] = (points[1] - points[0]) * (3.0 / (2 * l[0]))

    _a[num - 1] = [1, 2, 0]
    _b[num - 1] = (points[num - 1] - points[num - 2]) * (3.0 / l[num - 2])

    (1...(num - 1)).each do |i|
      a = l[i - 1]
      b = l[i]
      _a[i] = [b, 2.0 * (b + a), a]
      _b[i] = (((points[i + 1] - points[i]) * 3.0 * a * a) + ((points[i] - points[i - 1]) * 3.0 * b * b)) / (b * a)
    end
    (1...num).each do |i|
      d = _a[i - 1][1] / _a[i][0]

      _a[i] = [0, _a[i][1] * d - _a[i - 1][2], _a[i][2] * d]
      _b[i] = (_b[i] * d) - _b[i - 1]

      _a[i][2] /= _a[i][1]
      _b[i].x /= _a[i][1]
      _b[i].y /= _a[i][1]
      _a[i][1] = 1
    end

    _c[num - 1] = _b[num - 1]
    j = num - 1
    while j > 0
      # ベクトル同士のかけ算のメソッドを用意してないためこれでいい
      _c[j - 1] = vec2[
        _b[j - 1].x - _a[j - 1][2] * _c[j].x,
        _b[j - 1].y - _a[j - 1][2] * _c[j].y,
      ]
      j -= 1
    end

    out = []
    frame_counter = 0
    (num - 1).times do |i|
      a = l[i]
      _v00 = points[i].x
      _v01 = _c[i].x
      _v02 = (points[i + 1].x - points[i].x) * 3 / (a * a) - (_c[i + 1].x + 2 * _c[i].x) / a
      _v03 = (points[i + 1].x - points[i].x) * (-2 / (a * a * a)) + (_c[i + 1].x + _c[i].x) * (1 / (a * a))
      _v10 = points[i].y
      _v11 = _c[i].y
      _v12 = (points[i + 1].y - points[i].y) * 3 / (a * a) - (_c[i + 1].y + 2 * _c[i].y) / a
      _v13 = (points[i + 1].y - points[i].y) * (-2 / (a * a * a)) + (_c[i + 1].y + _c[i].y) * (1 / (a * a))

      t = 0.0
      interpolate.times {
        out << vec2[
          ((_v03 * t + _v02) * t + _v01) * t + _v00,
          ((_v13 * t + _v12) * t + _v11) * t + _v10,
        ]
        t += a / interpolate
      }
    end

    out << points.last

    out
  end

  run
end
