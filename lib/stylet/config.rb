# -*- coding: utf-8 -*-
require "active_support/configurable"

module Stylet
  include ActiveSupport::Configurable

  config_accessor :production

  config.screen_size      = [640, 480]
  config.full_screen      = false
  config.color_depth      = 16
  config.screen_options   = SDL::HWSURFACE | SDL::DOUBLEBUF # SDL::NOFRAME

  config.sound_freq       = 44100  # SDLのデフォルトは 22050

  # config.font_name      = "luxirr.ttf"
  config.font_name        = "ipag-mona.ttf"

  config.font_size        = 18
  config.font_bold        = false

  config.background_image = nil # "background.bmp"

  config.pause_keys       = [SDL::Key::SPACE]

  config.optparse_enable  = true

  config.production       = false
  config.production_keys  = [SDL::Key::RETURN]
end
