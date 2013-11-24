# -*- coding: utf-8 -*-
require "active_support/configurable"

module Stylet
  include ActiveSupport::Configurable

  config.screen_size      = [640, 480]
  config.full_screen      = false
  config.color_depth      = 32
  config.production       = false

  config.sound_freq       = 44100  # SDLのデフォルトは 22050

  # config.font_name      = "luxirr.ttf"
  config.font_name        = "ipag-mona.ttf"

  config.font_size        = 18
  config.font_margin      = 3 # 行
  config.font_bold        = false

  config.background       = false
  config.background_image = "background.bmp"
end
