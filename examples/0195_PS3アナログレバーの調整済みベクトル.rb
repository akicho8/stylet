# -*- coding: utf-8 -*-
# PS3のコントローラーはアナログレバーは見た目は円だけど内部では四角
require "./setup"

Stylet.run do
  joys.each do |joy|
    joy.adjusted_analog_lever.each do |key, vector|
      vputs [key, vector]
      draw_vector(vector * (rect.height / 2), :origin => rect.center, :label => vector.round(2))
    end
  end
  draw_circle(rect.center, :vertex => 64, :radius => rect.height / 2)
end
