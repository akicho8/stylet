require "active_support/configurable"

module Stylet
  include ActiveSupport::Configurable

  config_accessor :production

  # Screen
  config.screen_size      = [640, 480]
  config.fps              = nil
  config.full_screen      = false
  config.color_depth      = 16
  config.screen_flags     = 0
  # config.screen_flags     = SDL2::HWSURFACE | SDL2::DOUBLEBUF | SDL2::HWACCEL | SDL2::RESIZABLE
  # config.screen_flags   = SDL2::HWSURFACE | SDL2::DOUBLEBUF | SDL2::HWACCEL | SDL2::RESIZABLE # SDL2::NOFRAME
  # config.screen_flags   = SDL2::HWSURFACE | SDL2::DOUBLEBUF | SDL2::HWACCEL | SDL2::RESIZABLE | SDL2::SRCALPHA

  config.renderer_flags   =  SDL2::Renderer::Flags::ACCELERATED | SDL2::Renderer::Flags::PRESENTVSYNC

  config.background_image = nil # "background.bmp"

  # Font
  config.system_font_key = :ipag_mona
  config.font_list = [
    {:key => :ipag_mona,            :path => "ipag-mona.ttf",           :bold => false, :font_size => 14},
    # {:key => :font_large, :path => "LiberationMono-Bold.ttf", :bold => true,  :font_size => 24},
    # {:key => :coda,       :path => "Coda-Regular.ttf",        :bold => false, :font_size => 14},
  ]

  # Mouse
  config.hide_mouse       = false

  # Audio
  config.sound_freq       = 22050 # 44100  # SDLのデフォルトは 22050
  config.music_mute       = false
  config.mute             = false

  # etc.
  config.production       = false
  config.production_keys  = [SDL2::Key::K0] # [SDL2::Key::RETURN]
  config.pause_keys       = [SDL2::Key::SPACE]
  config.optparse_skip    = false
end
