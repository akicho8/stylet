require "active_support/configurable"

module Stylet2
  include ActiveSupport::Configurable

  config.full_screen       = false
  config.font_size         = 16
  config.fps_console_print = false
end
