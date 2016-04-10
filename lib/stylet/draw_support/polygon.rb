#
# 多角形描画
#
module Stylet
  module DrawSupport
    # 多角形描画
    #   draw_polygon([Vector.zero, vec2[0, 100], vec2[50, 50]])
    def draw_polygon(points, options = {})
      (points + points.take(1)).each_cons(2) {|a, b| draw_line(a, b, options) }
    end
  end
end

if $0 == __FILE__
  require_relative "../../stylet"
  Stylet::Base.run do
    points = Array.new(3 + rand(3)) {vec2[rand(srect.w), rand(srect.h)]}
    draw_polygon(points)
    draw_polygon([Stylet::Vector.zero, vec2[0, 100], vec2[50, 50]])
    sleep(0.25)
  end
end
