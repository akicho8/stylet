# -*- coding: utf-8 -*-
require "./setup"
Stylet.run(:title => "マウス確認") do
  vputs mouse
  draw_vector(mouse.vector, :origin => rect.center, :label => mouse.vector.magnitude)
end
