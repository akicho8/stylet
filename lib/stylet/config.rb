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
  config.production_keys  = [SDL::Key::K0] # [SDL::Key::RETURN]
  config.pause_keys       = [SDL::Key::SPACE]
  config.optparse_skip    = false
end
