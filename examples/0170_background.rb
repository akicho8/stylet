# -*- coding: utf-8 -*-
require "./setup"

Stylet.config.configure do |config|
  config.background = true
  config.background_image = "background.bmp"
end

Stylet.run(:title => "背景にPNGを描画する例")
