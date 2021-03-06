# FF7の戦闘に入るときのエフェクト

require_relative "helper"
require "matrix"

Stylet.configure do |config|
  config.screen_size = [640, 480]
  config.production = true
end

class App < Stylet::Base
  include Helper::Cursor

  setup do
    SDL::Mouse.hide
    screen.set_alpha(SDL::SRCALPHA, 128)
  end

  update do
    if button.btA.trigger? || frame_counter == 0 || frame_counter.modulo(60).zero?
      f = Pathname.glob("assets/bg*.png").to_a.sample
      s = SDL::Surface.load(f.to_s)
      image = s.display_format
      SDL::Surface.transform_draw(image, screen, 0, 1.00, 1.00, image.w / 2, image.h / 2, *srect.center, SDL::Surface::TRANSFORM_AA)
    end
  end

  def background_clear
    SDL::Surface.transform_blit(screen, screen, 2, 1.05, 1.05, *srect.center, *srect.center, SDL::Surface::TRANSFORM_AA | SDL::Surface::TRANSFORM_SAFE)
  end

  run
end
