#
# 円の描画
#
require "./setup"

Stylet.run(:title => "円の描画") do
  draw_circle(srect.center, :vertex => 256)
end
