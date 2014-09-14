# -*- coding: utf-8 -*-
require "./setup"
Stylet.context.run(:title => "(title)") do
  Stylet.context.vputs Stylet.context.frame_counter
end
