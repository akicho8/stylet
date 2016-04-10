# フォント関連
require "./setup"

Stylet.run do
  vputs "left",   :vector => srect.center + [0, system_font.line_skip * 0], :align => :left
  vputs "center", :vector => srect.center + [0, system_font.line_skip * 1], :align => :center
  vputs "right",  :vector => srect.center + [0, system_font.line_skip * 2], :align => :right
end
