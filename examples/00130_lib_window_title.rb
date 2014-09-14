# -*- coding: utf-8 -*-
require "./setup"

Stylet.run(:title => "(window_title)") do
  vputs title
  if frame_counter >= 60
    self.title = frame_counter.to_s
  end
end
