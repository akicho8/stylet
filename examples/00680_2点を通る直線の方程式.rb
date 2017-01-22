#
# 2点を通る直線の方程式
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @p0 = srect.center + vec2[-srect.w / 4, rand(srect.h / 4)] # 左の点
    @p1 = srect.center + vec2[+srect.w / 4, rand(srect.h / 4)] # 右の点
    self.title = "2点を通る直線の方程式"
    @x_mode = true
  end

  update do
    update_movable_points([@p0, @p1])
    [@p0, @p1].each_with_index {|e, i|vputs("p#{i} #{e}", :vector => e)}

    if button.btC.trigger?
      @x_mode = !@x_mode
    end

    # ２点から直線の式の求め方 - Yahoo!知恵袋 の ju_tateru さんの回答より
    # http://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q1255399312
    # > したがって、(x0,y0),(x1,y1)を通る直線は
    # > (y0 - y1)x - (x0 - x1)y + x0y1 - x1y0 = 0
    # > と表せます。
    #
    # なので ax + by + c = 0 の部分の a b c は次のようになる
    a = @p0.y - @p1.y
    b = -(@p0.x - @p1.x)
    c = (@p0.x * @p1.y - @p1.x * @p0.y)
    # あとは ax + by + c = 0 を入れ替えて
    # x から y を求めるなら y = (-c + -a * x) / b
    # y から x を求めるなら x = (-c + -b * y) / a
    # となる

    # ax + by + c = 0 の場合の傾きとy切片は次のようになるらしい
    # 傾き: -a/b
    # y切片: -c/b

    katamuki = -a.to_f / b
    y_seppen = -c.to_f / b

    if @x_mode
      # X軸を等速で動かしてYを求める場合
      x_range = ((srect.center.x - srect.w / 4)..(srect.center.x + srect.w / 4))
      x_range.begin.step(x_range.end, 16) do |x|
        # y = (((@p1.y - @p0.y).to_f / (@p1.x - @p0.x)) * (x - @p0.x)) + @p0.y # ← こっちでもいい
        y = (-c + -a * x).to_f / b
        v = vec2[x, y]
        draw_triangle(v, :radius => 4, :vertex => 4)
      end
    else
      # Y軸を等速で動かしてXを求める場合
      y_range = ((srect.center.y - srect.h / 4)..(srect.center.y + srect.h / 4))
      y_range.begin.step(y_range.end, 16) do |y|
        # x = (((y - @p0.y) * (@p1.x - @p0.x)).to_f / (@p1.y - @p0.y)) + @p0.x # ← こっちでもいい
        x = (-c + -b * y).to_f / a
        v = vec2[x, y]
        draw_triangle(v, :radius => 4, :vertex => 4)
      end
    end

    # (y1-y0)x -(x1-x0)y -{(y1-y0)x0+(x1-x0)y0} = 0
    # ^^^^^^^  ^^^^^^^^   ^^^^^^^^^^^^^^^^^^^^^
    # a      x +    b  y + c

    vputs " ax+by+c=0 => #{a}x + #{b}y + #{c} = 0"
    vputs " 傾き -a/b => #{katamuki}"
    vputs "y切片 -c/b => #{y_seppen}"

    vputs "p0:#{@p0}"
    vputs "p1:#{@p1}"
    vputs "A:left point move B:right point move C:x y toggle"
  end

  run
end
