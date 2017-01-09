# アフィン変換

require_relative "helper"
require_relative "mtx33"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
  end

  update do
    if true
      # 絶対座標の場合
      p0 = srect.center                              # オブジェクトの原点
      p1 = p0 + vec2[64, 64]                         # 絶対座標になっている場合は、
      m1 = Stylet::Mtx33.translate(*(-p0))           # まず原点を引いて
      m2 = Stylet::Mtx33.rotate(frame_counter)       # モデル座標の状態にして回転し
      m3 = Stylet::Mtx33.translate(*p0)              # 元に戻す
      m = Stylet::Mtx33.transform(m1, m2, m3)        # 上の3つの行列を加算
      # m = Stylet::Mtx33.invert(m)
      v = Stylet::Mtx33.vec2_transform_point(*p1, m) # 絶対座標を反映
      draw_triangle(v, :radius => 16)
      draw_dot(p0)
    end

    if true
      # モデル座標の場合
      p0 = srect.center                              # オブジェクトの原点
      p1 = vec2[128, 128]                            # モデル座標
      m = Stylet::Mtx33.rotate(frame_counter)        # モデル座標の場合はいきなり回転してよい
      v = Stylet::Mtx33.vec2_transform_point(*p1, m) # モデル座標を反映
      draw_triangle(p0 + v, :radius => 16)           # 最後に原点を普通に足す
      draw_dot(p0)
    end
  end

  run
end
