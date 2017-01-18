#
# 円同士の当り判定(ベクトルを使った方法)
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "円の押し引き"

    # カーソルを円として使う
    cursor.radius = 100
    cursor.vertex = 32

    @pos = srect.center.clone
    @radius = 100
  end

  update do
    a = cursor.point
    ar = cursor.radius

    b = @pos
    br = @radius

    r2 = ar + br
    if a != b
      diff = b - a
      rdiff = r2 - diff.magnitude
      if button.btA.press?
        vputs "PUSH"
        if rdiff > 0
          # a = b + diff.normalize * r2 # Bを基点に押し出す
          b += diff.normalize * rdiff    # Aを基点に押し出す
        end
      end
      if button.btB.press?
        vputs "PULL"
        if rdiff < 0
          # a = b + diff.normalize * r2 # Bを基点に戻す
          b += diff.normalize * rdiff    # Aを基点に戻す
        end
      end
      vputs "DIFF=#{diff.magnitude}"
      vputs "RDIFF=#{rdiff}"
    end

    @pos = b

    draw_line(@pos, cursor.point)
    draw_circle(@pos, :radius => @radius, :vertex => 32)
  end

  run
end
