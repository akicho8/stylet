# -*- coding: utf-8 -*-
require "active_support/configurable"

module Stylet
  include ActiveSupport::Configurable

  config_accessor :production

  # Screen
  config.screen_size      = [640, 480]
  config.fps              = nil
  config.full_screen      = false
  config.color_depth      = 16
  config.screen_flags     = SDL::HWSURFACE | SDL::DOUBLEBUF | SDL::HWACCEL | SDL::RESIZABLE
  # config.screen_flags   = SDL::HWSURFACE | SDL::DOUBLEBUF | SDL::HWACCEL | SDL::RESIZABLE # SDL::NOFRAME
  # config.screen_flags   = SDL::HWSURFACE | SDL::DOUBLEBUF | SDL::HWACCEL | SDL::RESIZABLE | SDL::SRCALPHA
  config.background_image = nil # "background.bmp"

  # Mouse
  config.hide_mouse       = false

  # Font
  config.font_size        = 14
  config.font_bold        = false
  config.font_name        = "ipag-mona.ttf"
  # config.font_name      = "luxirr.ttf"

  # Audio
  config.sound_freq       = 22050 # 44100  # SDLのデフォルトは 22050
  config.mute_music       = false
  config.mute             = false

  # etc.
  config.production       = false
  config.production_keys  = [SDL::Key::K0] # [SDL::Key::RETURN]
  config.pause_keys       = [SDL::Key::SPACE]
  config.optparse_skip    = false
end
