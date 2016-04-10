require_relative "helper"

Stylet.configure do |config|
  config.screen_size = [320 / 4, 240 / 4]
end

class App < Stylet::Base
  setup do
    SDL::Mouse.hide
  end

  update do
    screen.h.times.each do |y|
      screen.w.times.each do |x|
        r = 127 * Stylet::Fee.rsin(1.0 / 256 / 2 * frame_counter * x)
        g = 0
        b = 127 * Stylet::Fee.rsin(1.0 / 256 / 2 * frame_counter * y)
        screen[x, y] = screen.format.map_rgb(r, g, b)
      end
    end
  end

  def background_clear
  end

  run
end
