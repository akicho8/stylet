# -*- coding: utf-8 -*-
require_relative "setup"

Stylet.run(:title => "(window_title)") do
  vputs title
  if @count >= 60
    self.title = @count.to_s
  end
end
