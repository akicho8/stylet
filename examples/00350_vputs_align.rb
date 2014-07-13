# -*- coding: utf-8 -*-
# フォント関連
require "./setup"

Stylet.run do
  vputs "left",   :vector => rect.center + [0, font.line_skip * 0], :align => :left
  vputs "center", :vector => rect.center + [0, font.line_skip * 1], :align => :center
  vputs "right",  :vector => rect.center + [0, font.line_skip * 2], :align => :right
end
