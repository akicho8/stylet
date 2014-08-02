# -*- coding: utf-8 -*-
#
# 円の描画
#
require "./setup"

Stylet.run(:title => "円の描画") do
  draw_circle(rect.center, :vertex => 256)
end
