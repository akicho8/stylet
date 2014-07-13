# -*- coding: utf-8 -*-
require_relative "bezier"

class App
  def collection
    list = []

    # 横に配置
    n = 2
    a = []
    a += Array.new(n + 1){|i|
      x = (rect.width * 0.1) + ((rect.width * 0.8) / n * i)
      y = rect.hy
      Stylet::Vector.new(x, y)
    }
    list << a

    # 円状に配置
    n = 5
    r = rect.hy * 0.9
    a = []
    a += Array.new(n){|i|
      rect.center + Stylet::Vector.angle_at(1.0 / n * i).scale(r)
    }

    list << a

    list
  end

  update do
    unless @points.empty?
      if button.btB.trigger?
        # 最後に制御点の追加
        @points = [
          @points.first(@points.size - 1),
          @points.last + Stylet::Vector.new(-30, 0),
          @points.last,
        ].flatten
      end
      if button.btC.trigger?
        # 最後の制御点を削除
        if @points.size >= 3
          @points[-2] = nil
          @points.compact!
        end
      end
      vputs "#{@points.size} (B+ C-)"
    end
  end

  # N次ベジェ曲線
  #
  #         p1  p2  p3  p4
  #   p0 ------------------- p5
  #
  #   用途
  #   ・めちゃくちゃ激しく曲げたい
  #   ・終了座標を必ず通る必要がある
  #   ・どんだけ計算量がかかってもよい
  #   ・クロスしまくりたい
  #
  def bezier_curve(*points, d)
    o = Stylet::Vector.zero

    points.size.times{|i|
      p = points[i]
      v = 1.0
      a = points.size - 1
      b = i
      c = a - b
      loop do
        if a > 1
          v *= a
          a -= 1
        else
          break
        end
        if b > 1
          v /= b
          b -= 1
        end
        if c > 1
          v /= c
          c -= 1
        end
      end
      v *= (d ** i) * ((1 - d) ** ((points.size - 1) - i))
      o += p.scale(v)
    }
    o
  end

  run
end
