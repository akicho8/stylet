# -*- coding: utf-8 -*-

require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    @line_count = 50        # 軌跡確認用弧線の構成ライン数初期値(確認用)
    @points_count = 0

    points_switch
  end

  update do
    if key_down?(SDL::Key::A)
      points_switch
    end

    if false
      # 構成ライン数の減算
      @line_count += button.btC.repeat
      @line_count -= button.btD.repeat
      @line_count = [2, @line_count].max
      vputs "@line_count = #{@line_count}"
    end

    # 曲線表示
    if @dragging_current || button.btA.press? || true
      curve_points.each_cons(2) {|points| draw_line(*points) }
    end

    # ベジェのポイントを動かして表示
    update_movable_points(@points)
    @points.each_with_index{|e, i|vputs("b#{i} #{e}", :vector => e)}

    unless @points.empty?
      # 物体をいったりきたりさせる
      if false
        # ○の表示
        pos = 0.5 + (Stylet::Fee.rsin(count / 256.0) * 0.5)
        pt = point_of_t(pos)
        draw_circle(pt, :radius => 64, :vertex => 32)
        vputs(pos)
      else
        # △の表示で進んでいる方向を頂点にする
        t0 = 0.5 + (Stylet::Fee.rsin(1.0 / 256 * count) * 0.5)       # 現在の位置(0.0〜1.0)
        t1 = 0.5 + (Stylet::Fee.rsin(1.0 / 256 * count.next) * 0.5)  # 未来の位置(0.0〜1.0)
        p0 = point_of_t(t0)                                              # 現在の座標
        p1 = point_of_t(t1)                                              # 未来の座標
        draw_triangle(p0, :angle => p0.angle_to(p1), :radius => 64) # 三角の頂点を未来への向きに設定して三角描画
      end
    end
  end

  def points_switch
    @dragging_current = nil
    @points = collection[@points_count.modulo(collection.size)].tap { @points_count += 1}
  end

  private

  def curve_points
    @line_count.next.times.collect {|i| point_of_t(1.0 * i / @line_count) }
  end

  def point_of_t(t)
    bezier_curve(*@points.collect{|e|e}, t)
  end

  def bezier_curve(*args)
    raise NotImplementedError, "#{__method__} is not implemented"
  end
end

# 直線との交点
class App
  module LineCollision
    extend ActiveSupport::Concern

    included do
      setup do
        @lpoints_count = 0
        lpoints_switch
      end

      update do
        if key_down?(SDL::Key::S)
          lpoints_switch
        end

        # 直線のポイント位置のドラッグ
        update_movable_points(@line_ab)

        # ライン両端の番号とライン表示
        @line_ab.each_with_index{|e, i|vputs("p#{i} #{e}", :vector => e)}
        draw_line(*@line_ab)

        # 2点から直線 ax+bx+c=0 の a b c を求める
        p0 = @line_ab[0]
        p1 = @line_ab[1]
        a = p0.y - p1.y
        b = -(p0.x - p1.x)
        c = p0.x * p1.y - p1.x * p0.y

        t = intersection2(*@points, a, b, c)
        t.each do |t|
          xy = point_of_t(t)
          draw_circle(xy, :radius => 3)
          vputs(t, :vector => xy)
        end
      end
    end

    def lpoints_switch
      @line_ab = []
      if @lpoints_count.modulo(2).zero?
        @line_ab << rect.center + Stylet::Vector.new(-rect.w / 8, +rect.h / 3)
        @line_ab << rect.center + Stylet::Vector.new(-rect.w / 8, -rect.h / 3)
      else
        @line_ab << rect.center + Stylet::Vector.new(-rect.w / 8, 0)
        @line_ab << rect.center + Stylet::Vector.new(+rect.w / 8, 0)
      end
      @dragging_current = nil
      @lpoints_count += 1
    end

    # NUTSU » [as]ベジェ曲線と直線の交点
    # http://nutsu.com/blog/2007/101701_as_bezjesegment3.html
    def intersection1(p0, p1, p2, a, b, c)
      t = []

      m = b*p2.y+b*p0.y+a*p2.x+a*p0.x-2*b*p1.y-2*a*p1.x
      n = -2*b*p0.y-2*a*p0.x+2*b*p1.y+2*a*p1.x
      l = b*p0.y+a*p0.x+c

      d = (n**2)-4*m*l

      vputs "a: #{a}"
      vputs "b: #{b}"
      vputs "c: #{c}"

      vputs "l: #{l}"
      vputs "m: #{m}"
      vputs "n: #{n}"
      vputs "d: #{d}"

      if d > 0
        d = Math.sqrt(d)
        t << 0.5 * (-n + d) / m
        t << 0.5 * (-n - d) / m
      elsif d.zero?
        t << 0.5 * -n / m
      end

      vputs "t: #{t}"

      t = t.find_all{|d|(0..1).include?(d)} # (0..1の範囲外は曲線の延長線上の交点になる)
      t
    end

    # 二次ベジェ曲線と直線の交点
    # http://geom.web.fc2.com/geometry/bezier/qb-line-intersection.html
    def intersection2(p0, p1, p2, a, b, c)
      t = []

      l = a*(p2.x-2*p1.x+p0.x)+b*(p2.y-2*p1.y+p0.y)
      m = 2*(a*(p1.x-p0.x)+b*(p1.y-p0.y))
      n = a*p0.x+b*p0.y+c

      # 交点があるにもかかわらず t = [Nan, -Infinity] になってしまう場合がある
      # このとき l が 0 になっているので、次のようにごまかせば交点が生まれたけど、計算が間違っている気がする
      # if l.zero?
      #   l = 0.000000001
      # end

      d = (m**2)-4*l*n

      vputs "a: #{a}"
      vputs "b: #{b}"
      vputs "c: #{c}"

      vputs "l: #{l}"
      vputs "m: #{m}"
      vputs "n: #{n}"
      vputs "d: #{d}"

      if d > 0
        s = Math.sqrt(d)
        t << (-m+s) / (2*l)
        t << (-m-s) / (2*l)
      elsif d.zero?
        t << -m/(2*l)
      end

      vputs "t: #{t}"

      t = t.find_all{|d|(0..1).include?(d)} # (0..1の範囲外は曲線の延長線上の交点になる)
      t
    end
  end
end
