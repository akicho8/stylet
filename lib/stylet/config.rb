# -*- coding: utf-8 -*-
require "active_support/configurable"

module Stylet
  include ActiveSupport::Configurable

  config_accessor :production

  config.fps              = nil,
  config.screen_size      = [640, 480]
  config.full_screen      = false
  config.color_depth      = 16
  config.screen_flags     = SDL::HWSURFACE | SDL::DOUBLEBUF | SDL::HWACCEL | SDL::RESIZABLE # SDL::NOFRAME

  config.sound_freq       = 22050 # 44100  # SDLのデフォルトは 22050

  # config.font_name      = "luxirr.ttf"
  config.font_name        = "ipag-mona.ttf"

  config.font_size        = 14
  config.font_bold        = false

  config.background_image = nil # "background.bmp"

  config.pause_keys       = [SDL::Key::SPACE]

  config.optparse_enable  = true

  config.production       = false
  config.production_keys  = [SDL::Key::K0] # [SDL::Key::RETURN]

  config.silent_music     = false
  config.silent_all       = false
  config.hide_mouse       = false
end
