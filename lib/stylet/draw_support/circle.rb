#
# 円・三角形・四角形の描画(向きの指定可)
#
module Stylet
  module DrawSupport
    # 多角形の描画
    #   四角形
    #     win.draw_circle(win.srect.center, :vertex => 4)
    #   三角形で頂点の向きは時計の6時で半径256ピクセル
    #     win.draw_circle(win.srect.center, :vertex => 3, :angle => Magic.r90, :radius => 256)
    def draw_circle(p0, options = {})
      options = {
        :radius => 64,       # 半径
        :vertex => 8,        # n角形
        :angle  => Magic.r270, # 開始地点(初期値は時計の12時)
      }.merge(options)

      raise "options[:vertex] is not Integer" unless options[:vertex].is_a? Integer
      raise "options[:vertex] >= 1" if options[:vertex].to_i.zero?
      raise "zero vector" if options[:vertex].zero?

      points = options[:vertex].times.collect do |i|
        a = options[:angle] + 1.0 * i / options[:vertex]
        p0 + Vector.angle_at(a) * options[:radius]
      end
      draw_polygon(points, options)
    end

    # 三角形版
    def draw_triangle(p0, options = {})
      draw_circle(p0, {:vertex => 3}.merge(options))
    end

    # 四角形版
    def draw_square(p0, options = {})
      draw_circle(p0, {:vertex => 4}.merge(options))
    end

    # 長方形
    def draw_angle_rect(p0, options = {})
      options = {
        :radius => 64,       # 半径
        :angle  => Magic.r270, # 長方形の細長い部分の方向
        :edge => 1.0 / 16,   # 長方形の細長い先っぽの面の大きさ(0なら一本線。0.125で正方形)
      }.merge(options)
      s = options[:edge]
      points = [-s, s, 1.0 / 2 - s, 1.0 / 2 + s].collect do |rad|
        p0 + Vector.angle_at(options[:angle] + rad) * options[:radius]
      end
      draw_polygon(points, options)
    end
  end
end

if $0 == __FILE__
  require_relative "../../stylet"
  Stylet::Base.run do
    draw_circle(srect.center)
    draw_triangle(srect.center)
    draw_square(srect.center)
    draw_angle_rect(srect.center)
  end
end
