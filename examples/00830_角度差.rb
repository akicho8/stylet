require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @dirs = Array.new(2) {0}
  end

  update do
    angle = (cursor.point - srect.center).angle
    if button.btA.press?
      @dirs[1] = angle
    end
    if button.btB.press?
      @dirs[0] = angle
    end

    @dirs.each do |dir|
      draw_vector(vec2.angle_at(dir) * srect.height / 4, :origin => srect.center, :label => dir.round(2))
      vputs "dir: #{dir.round(2)}"
    end

    # 以下はライブラリでメソッド化してある
    # 0 は 1 に向う
    sub = @dirs[1].modulo(1.0) - @dirs[0].modulo(1.0)
    if sub < -1.0 / 2
      sub = 1.0 + sub
    elsif sub > 1.0 / 2
      sub = -1.0 + sub
    end
    @dirs[0] += sub * 0.1
  end

  run
end
