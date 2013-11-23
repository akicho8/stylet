# -*- coding: utf-8 -*-
# atan で atan2 を書く
require_relative "helper"

class App < Stylet::Base
  update do
    vec = mouse.point - rect.center
    vputs "vec: #{vec}"
    x, y = vec.to_a

    v = Math.atan(y.to_f / x)
    if x < 0
      if y < 0
        v -= Math::PI
      else
        v += Math::PI
      end
    end
    vputs "atan:  #{v}"

    vputs "atan2: #{Math.atan2(y, x)}"
  end

  run
end
