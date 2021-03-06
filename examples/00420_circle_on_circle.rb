#
# 円上を動く円
#
require "./setup"
include Stylet

run(:title => "円上を動く円") do
  pos = Vector.angle_at(1.0 / 256 * frame_counter * 2) * srect.h * 0.3
  draw_circle(srect.center + pos, :vertex => 8, :radius => 64, :angle => pos.angle * 2)
end
